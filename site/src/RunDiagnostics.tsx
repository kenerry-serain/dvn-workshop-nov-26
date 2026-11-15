import type { ProcessingFailures, SendFailureSource } from '../../backend/shared/types';

const number = new Intl.NumberFormat('pt-BR').format;
const sourceLabels: Record<SendFailureSource, string> = {
  sqs: 'Publicação no SQS',
  apiGatewayThrottle: 'Limite de requisições do API Gateway',
  network: 'Rede ou timeout de envio',
  other: 'Outras respostas de envio',
};

export type LogGroups = {
  processor?: string;
  generator?: string;
  controller?: string;
  region?: string;
};

type Props = {
  sendErrors: number;
  sendFailures?: Partial<Record<SendFailureSource, number>>;
  processing?: ProcessingFailures;
  visibilitySeconds?: number;
  pending: number;
  logGroups?: LogGroups;
};

export default function RunDiagnostics({sendErrors, sendFailures, processing, visibilitySeconds, pending, logGroups}: Props) {
  const known = Object.entries(sendFailures || {}) as [SendFailureSource, number][];
  const unclassified = Math.max(0, sendErrors - known.reduce((sum, [, count]) => sum + count, 0));
  const retryAt = processing?.nextRetryAt;
  const labels = [
    ['processor', 'Processadora', 'Baixa de estoque, limitação do DynamoDB e novas tentativas do SQS FIFO.'],
    ['generator', 'Geradora', 'Envios ao SQS pelo API Gateway, códigos HTTP e falhas de rede.'],
    ['controller', 'Controladora', 'Inicialização do estoque, acionamento dos workers e leitura do relatório.'],
  ] as const;
  const region = logGroups?.region || 'us-east-1';
  const hasErrors = sendErrors > 0 || Boolean(processing?.attempts);
  return <section className={`panel diagnostics ${hasErrors ? 'diagnostics-errors' : ''}`} aria-label="Diagnóstico da execução">
    <h2>Diagnóstico da execução</h2>
    {hasErrors && <ul>
      {known.map(([source, count]) => <li key={source}><strong>{number(count)}</strong> · {sourceLabels[source]}</li>)}
      {unclassified > 0 && <li><strong>{number(unclassified)}</strong> · Falhas de envio sem origem identificada</li>}
      {processing && processing.attempts > 0 && <li>
        <strong>{number(processing.attempts)}</strong> tentativas de processamento com falha em <strong>{number(processing.batches)}</strong> lotes{processing.dynamoThrottled === processing.attempts && ' por throttling do DynamoDB'}.
        {processing.dynamoThrottled > 0 && processing.dynamoThrottled < processing.attempts && <> Dessas, <strong>{number(processing.dynamoThrottled)}</strong> foram por throttling do DynamoDB.</>}
        {' '}Um pedido pode aparecer em mais de uma tentativa.
      </li>}
    </ul>}
    {Boolean(processing?.dynamoThrottled) && <p>Confira o Warm Throughput de escrita do DynamoDB e a concorrência da processadora antes de repetir a carga.</p>}
    {(!processing?.available || processing.partial) && <p>{processing?.partial ? 'A contagem de processamento é parcial.' : 'A contagem de falhas de processamento está indisponível para este relatório.'} Confira os logs da processadora.</p>}
    {pending > 0 && <p><strong>{number(pending)} pedidos aguardam processamento.</strong> Já foram aceitos na fila e ainda não têm resultado final. {processing?.attempts
      ? <>O SQS tenta de novo automaticamente após a visibilidade expirar. No FIFO, os pedidos seguintes do mesmo grupo aguardam. {visibilitySeconds ? `A visibilidade atual da fila é ${visibilitySeconds} s para novos recebimentos. ` : ''}{retryAt && retryAt > Date.now() ? `Próxima tentativa estimada por volta de ${new Date(retryAt).toLocaleTimeString('pt-BR', {timeZone: 'America/Sao_Paulo'})} de Brasília. ` : ''}O painel continua consultando o progresso.</>
      : 'O painel continua consultando o processamento da fila.'}</p>}
    <details open={hasErrors || undefined}>
      <summary>Onde investigar no CloudWatch</summary>
      <ul>{labels.map(([key, label, detail]) => {
        const group = logGroups?.[key];
        const url = group ? `https://${region}.console.aws.amazon.com/cloudwatch/home?region=${region}#logsV2:log-groups/log-group/${encodeURIComponent(encodeURIComponent(group)).replace(/%/g, '$')}` : undefined;
        return <li key={key}>{url ? <a href={url} target="_blank" rel="noopener noreferrer">Lambda {label} ↗</a> : <strong>Lambda {label}</strong>} · {detail}</li>;
      })}</ul>
    </details>
  </section>;
}
