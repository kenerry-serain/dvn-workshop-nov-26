resource "aws_lambda_function" "generator" {
  function_name    = local.lambda_generator_name
  role             = aws_iam_role.generator.arn
  runtime          = var.lambda_runtime
  handler          = var.lambda_generator_handler
  architectures    = var.lambda_architectures
  timeout          = var.lambda_generator_timeout
  memory_size      = var.lambda_generator_memory_size
  filename         = local.lambda_generator_package_path
  source_code_hash = filebase64sha256(local.lambda_generator_package_path)

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
    log_group  = aws_cloudwatch_log_group.generator.name
  }

  depends_on = [
    aws_iam_role_policy_attachment.generator_logs,
    aws_iam_role_policy.generator,
  ]
}
