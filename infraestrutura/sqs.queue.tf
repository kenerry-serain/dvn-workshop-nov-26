resource "aws_sqs_queue" "orders_dlq" {
  name                        = local.sqs_dlq_name
  fifo_queue                  = var.sqs_fifo_queue_enabled
  content_based_deduplication = var.sqs_content_based_deduplication_enabled
  deduplication_scope         = var.sqs_dlq_deduplication_scope
  fifo_throughput_limit       = var.sqs_dlq_fifo_throughput_limit
  visibility_timeout_seconds  = var.sqs_dlq_visibility_timeout_seconds
  message_retention_seconds   = var.sqs_dlq_message_retention_seconds
  max_message_size            = var.sqs_dlq_max_message_size
  sqs_managed_sse_enabled     = var.sqs_managed_sse_enabled
}

resource "aws_sqs_queue" "orders" {
  name                        = local.sqs_orders_queue_name
  fifo_queue                  = var.sqs_fifo_queue_enabled
  content_based_deduplication = var.sqs_content_based_deduplication_enabled
  deduplication_scope         = var.sqs_orders_queue_deduplication_scope
  fifo_throughput_limit       = var.sqs_orders_queue_fifo_throughput_limit
  visibility_timeout_seconds  = var.sqs_orders_queue_visibility_timeout_seconds
  message_retention_seconds   = var.sqs_orders_queue_message_retention_seconds
  max_message_size            = var.sqs_orders_queue_max_message_size
  sqs_managed_sse_enabled     = var.sqs_managed_sse_enabled

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.orders_dlq.arn
    maxReceiveCount     = var.sqs_orders_queue_max_receive_count
  })
}

# Só a fila principal pode redirecionar mensagens para a DLQ.
resource "aws_sqs_queue_redrive_allow_policy" "orders_dlq" {
  queue_url = aws_sqs_queue.orders_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = var.sqs_dlq_redrive_permission
    sourceQueueArns   = [aws_sqs_queue.orders.arn]
  })
}
