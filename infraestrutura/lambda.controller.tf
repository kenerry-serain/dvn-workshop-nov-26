resource "aws_lambda_function" "controller" {
  function_name    = local.lambda_controller_name
  role             = aws_iam_role.controller.arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_controller_handler
  architectures    = var.lambda_architectures
  timeout          = var.lambda_controller_timeout
  memory_size      = var.lambda_controller_memory_size
  filename         = local.lambda_controller_package_path
  source_code_hash = filebase64sha256(local.lambda_controller_package_path)

  ephemeral_storage {
    size = var.lambda_ephemeral_storage_size
  }

  environment {
    variables = {
      TABLE               = aws_dynamodb_table.orders.name
      GENERATOR           = aws_lambda_function.generator.function_name
      PROCESSOR_LOG_GROUP = aws_cloudwatch_log_group.processor.name
      QUEUE               = aws_sqs_queue.orders.url
      DLQ                 = aws_sqs_queue.orders_dlq.url
    }
  }

  tracing_config {
    mode = var.lambda_tracing_mode
  }

  logging_config {
    log_format = var.lambda_log_format
    log_group  = aws_cloudwatch_log_group.controller.name
  }

  depends_on = [
    aws_iam_role_policy_attachment.controller_logs,
    aws_iam_role_policy.controller,
    aws_iam_role_policy.controller_processor_logs,
  ]

  lifecycle {
    # A própria função grava estas variáveis em runtime ao alterar a
    # visibilidade da fila do processor; o Terraform não deve revertê-las.
    ignore_changes = [
      environment[0].variables["PROCESSOR_VISIBILITY_CHANGED_AT_MS"],
      environment[0].variables["PROCESSOR_PREVIOUS_VISIBILITY_SECONDS"],
    ]
  }
}

# API Gateway -> controller: uma permissão por rota que usa a função.
resource "aws_lambda_permission" "controller" {
  for_each = local.api_gateway_runs_routes

  statement_id  = "${var.lambda_controller_permission_statement_id_prefix}-${each.key}"
  function_name = aws_lambda_function.controller.function_name
  action        = var.lambda_invoke_action
  principal     = var.iam_api_gateway_service_principal
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/${each.value.http_method}/${each.value.permission_path}"
}
