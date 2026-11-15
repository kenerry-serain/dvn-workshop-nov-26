import { CloudWatchLogsClient, FilterLogEventsCommand } from '@aws-sdk/client-cloudwatch-logs';
import type { ProcessingFailures } from '../shared/types.js';

const client = new CloudWatchLogsClient({ maxAttempts: 1 });
const refreshMs = 15_000;
const cache = new Map<string, { expires: number; result: Promise<ProcessingFailures> }>();

export function readProcessingFailures(runId: string, startTime: number, visibilitySeconds: number) {
  const logGroupName = process.env.PROCESSOR_LOG_GROUP;
  if (!logGroupName || !/^[0-9a-f-]{36}$/.test(runId)) return undefined;
  const existing = cache.get(runId);
  if (existing && existing.expires > Date.now()) return existing.result;
  if (cache.size >= 16) cache.delete(cache.keys().next().value!);

  const result = collect(logGroupName, runId, startTime, visibilitySeconds).catch(() => {
    // Logs are eventually consistent and diagrams should keep updating if diagnostics are unavailable.
    return { available: false, attempts: 0, batches: 0, dynamoThrottled: 0, partial: false };
  });
  cache.set(runId, { expires: Date.now() + refreshMs, result });
  return result;
}

async function collect(logGroupName: string, runId: string, startTime: number, visibilitySeconds: number): Promise<ProcessingFailures> {
  const summary: ProcessingFailures = { available: true, attempts: 0, batches: 0, dynamoThrottled: 0, partial: false };
  const signal = AbortSignal.timeout(4500);
  const endTime = Date.now();
  const visibilityChangedAt = Number(process.env.PROCESSOR_VISIBILITY_CHANGED_AT_MS || 0);
  const previousVisibilitySeconds = Number(process.env.PROCESSOR_PREVIOUS_VISIBILITY_SECONDS || visibilitySeconds);
  const seen = new Set<string>();
  let nextToken: string | undefined;

  for (let page = 0; page < 20; page++) {
    const result = await client.send(new FilterLogEventsCommand({
      logGroupName, startTime, endTime, filterPattern: `"ProcessorBatchFailed" "${runId}"`, nextToken,
    }), { abortSignal: signal }).catch((error: unknown) => {
      if (page === 0) throw error;
      return undefined;
    });
    if (!result) break;

    for (const entry of result.events || []) {
      const message = entry.message || '';
      const start = message.indexOf('{');
      if (start < 0 || !entry.eventId || seen.has(entry.eventId)) continue;
      let failure;
      try { failure = JSON.parse(message.slice(start)); } catch { continue; }
      if (failure.event !== 'ProcessorBatchFailed' || failure.runId !== runId) continue;
      seen.add(entry.eventId);
      const count = Number(failure.failedMessages) || 0;
      summary.batches++;
      summary.attempts += count;
      if (failure.operation === 'processInventory' &&
          /throttl|ProvisionedThroughputExceeded/i.test([failure.errorName, ...(failure.cancellationCodes || [])].join(' '))) {
        summary.dynamoThrottled += count;
      }
      const at = entry.timestamp || 0;
      const wait = visibilityChangedAt && at < visibilityChangedAt ? previousVisibilitySeconds : visibilitySeconds;
      const retryAt = at + wait * 1000;
      if (at > (summary.lastFailureAt || 0)) summary.lastFailureAt = at;
      if (at && retryAt > endTime && (!summary.nextRetryAt || retryAt < summary.nextRetryAt)) summary.nextRetryAt = retryAt;
    }
    if (!result.nextToken) return summary;
    if (result.nextToken === nextToken) break;
    nextToken = result.nextToken;
  }
  return { ...summary, partial: true };
}
