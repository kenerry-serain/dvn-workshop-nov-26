locals {
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  region     = data.aws_region.current.region

  # Nomes (valores com hífen): project_name + sufixo de cada recurso.
  dynamodb_table_name = "${var.project_name}-${var.dynamodb_table_name_suffix}"

  sqs_orders_queue_name = "${var.project_name}-${var.sqs_orders_queue_name_suffix}"
  sqs_dlq_name          = "${var.project_name}-${var.sqs_dlq_name_suffix}"

  lambda_controller_name = "${var.project_name}-${var.lambda_controller_name_suffix}"
  lambda_generator_name  = "${var.project_name}-${var.lambda_generator_name_suffix}"
  lambda_processor_name  = "${var.project_name}-${var.lambda_processor_name_suffix}"

  iam_sqs_role_name                         = "${var.project_name}-${var.iam_sqs_role_name_suffix}"
  iam_sqs_role_policy_name                  = "${var.project_name}-${var.iam_sqs_role_policy_name_suffix}"
  iam_controller_role_name                  = "${var.project_name}-${var.iam_controller_role_name_suffix}"
  iam_controller_logs_policy_name           = "${var.project_name}-${var.iam_controller_logs_policy_name_suffix}"
  iam_controller_policy_name                = "${var.project_name}-${var.iam_controller_policy_name_suffix}"
  iam_controller_processor_logs_policy_name = "${var.project_name}-${var.iam_controller_processor_logs_policy_name_suffix}"
  iam_generator_role_name                   = "${var.project_name}-${var.iam_generator_role_name_suffix}"
  iam_generator_logs_policy_name            = "${var.project_name}-${var.iam_generator_logs_policy_name_suffix}"
  iam_generator_policy_name                 = "${var.project_name}-${var.iam_generator_policy_name_suffix}"
  iam_processor_role_name                   = "${var.project_name}-${var.iam_processor_role_name_suffix}"
  iam_processor_logs_policy_name            = "${var.project_name}-${var.iam_processor_logs_policy_name_suffix}"
  iam_processor_policy_name                 = "${var.project_name}-${var.iam_processor_policy_name_suffix}"

  api_gateway_name            = "${var.project_name}-${var.api_gateway_name_suffix}"
  api_gateway_api_key_name    = "${var.project_name}-${var.api_gateway_api_key_name_suffix}"
  api_gateway_usage_plan_name = "${var.project_name}-${var.api_gateway_usage_plan_name_suffix}"

  s3_frontend_bucket_name                = "${var.project_name}-${var.s3_frontend_bucket_name_suffix}"
  cloudfront_frontend_name               = "${var.project_name}-${var.cloudfront_frontend_name_suffix}"
  cloudfront_frontend_origin_access_name = "${var.project_name}-${var.cloudfront_frontend_origin_access_control_name_suffix}"
  cloudfront_frontend_origin_id          = "${local.s3_frontend_bucket_name}-origin"

  # Log groups no padrão <prefixo>/<nome da função>.
  cloudwatch_log_group_controller_name = "${var.cloudwatch_log_group_name_prefix}/${local.lambda_controller_name}"
  cloudwatch_log_group_generator_name  = "${var.cloudwatch_log_group_name_prefix}/${local.lambda_generator_name}"
  cloudwatch_log_group_processor_name  = "${var.cloudwatch_log_group_name_prefix}/${local.lambda_processor_name}"

  # Pacotes das Lambdas.
  lambda_controller_package_path = "${path.module}/${var.lambda_packages_dir}/${var.lambda_controller_package_file}"
  lambda_generator_package_path  = "${path.module}/${var.lambda_packages_dir}/${var.lambda_generator_package_file}"
  lambda_processor_package_path  = "${path.module}/${var.lambda_packages_dir}/${var.lambda_processor_package_file}"

  # ARN de todos os recursos de logs da conta/região (logs:CreateLogGroup).
  cloudwatch_logs_wildcard_arn = "arn:${local.partition}:logs:${local.region}:${local.account_id}:*"

  # URI da integração API Gateway -> SQS (ação por path, na conta dona da fila).
  api_gateway_sqs_integration_uri = "arn:${local.partition}:apigateway:${local.region}:sqs:path/${local.account_id}/${local.sqs_orders_queue_name}"

  # Nome do path parameter, sem as chaves de api_gateway_run_path_part.
  api_gateway_run_path_parameter = trimsuffix(trimprefix(var.api_gateway_run_path_part, "{"), "}")
}
