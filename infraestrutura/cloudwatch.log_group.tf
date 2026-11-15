resource "aws_cloudwatch_log_group" "controller" {
  name              = local.cloudwatch_log_group_controller_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

resource "aws_cloudwatch_log_group" "generator" {
  name              = local.cloudwatch_log_group_generator_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}

resource "aws_cloudwatch_log_group" "processor" {
  name              = local.cloudwatch_log_group_processor_name
  retention_in_days = var.cloudwatch_log_group_retention_in_days
}
