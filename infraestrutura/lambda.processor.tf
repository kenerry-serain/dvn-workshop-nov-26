resource "aws_lambda_function" "processor" {
  function_name    = local.lambda_processor_name
  role             = aws_iam_role.processor.arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_processor_handler
  architectures    = var.lambda_architectures
  timeout          = var.lambda_processor_timeout
  memory_size      = var.lambda_processor_memory_size
  filename         = local.lambda_processor_package_path
  source_code_hash = filebase64sha256(local.lambda_processor_package_path)

  ephemeral_storage {
    size = var.lambda_ephemeral_storage_size
  }

  environment {
    variables = {
      TABLE = aws_dynamodb_table.orders.name
    }
  }

  tracing_config {
    mode = var.lambda_tracing_mode
  }

  logging_config {
    log_format = var.lambda_log_format
    log_group  = aws_cloudwatch_log_group.processor.name
  }

  depends_on = [
    aws_iam_role_policy_attachment.processor_logs,
    aws_iam_role_policy.processor,
  ]
}

# Trigger SQS -> processor.
resource "aws_lambda_event_source_mapping" "processor" {
  event_source_arn                   = aws_sqs_queue.orders.arn
  function_name                      = aws_lambda_function.processor.arn
  enabled                            = var.lambda_processor_event_source_mapping_enabled
  batch_size                         = var.lambda_processor_batch_size
  maximum_batching_window_in_seconds = var.lambda_processor_maximum_batching_window_in_seconds
  function_response_types            = var.lambda_processor_function_response_types

  lifecycle {
    # A API devolve metrics_config vazio, que o provider não aceita declarar.
    ignore_changes = [metrics_config]
  }
}
