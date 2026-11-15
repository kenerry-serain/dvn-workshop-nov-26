# Role da Lambda controller: orquestra execuções, consulta fila, DynamoDB e logs.

data "aws_iam_policy_document" "controller_logs" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = [local.cloudwatch_logs_wildcard_arn]
  }

  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.controller.arn}:*"]
  }
}

data "aws_iam_policy_document" "controller" {
  statement {
    sid = "Dynamodb"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:PutItem",
      "dynamodb:Query",
    ]
    resources = [aws_dynamodb_table.orders.arn]
  }

  statement {
    sid       = "InvokeGenerator"
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.generator.arn]
  }

  statement {
    sid       = "ReadQueueAttributes"
    actions   = ["sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.orders.arn, aws_sqs_queue.orders_dlq.arn]
  }
}

data "aws_iam_policy_document" "controller_processor_logs" {
  statement {
    actions   = ["logs:FilterLogEvents"]
    resources = ["${aws_cloudwatch_log_group.processor.arn}:*"]
  }
}

resource "aws_iam_role" "controller" {
  name               = local.iam_controller_role_name
  path               = var.iam_lambda_role_path
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "controller_logs" {
  name   = local.iam_controller_logs_policy_name
  path   = var.iam_lambda_role_path
  policy = data.aws_iam_policy_document.controller_logs.json
}

resource "aws_iam_role_policy_attachment" "controller_logs" {
  role       = aws_iam_role.controller.name
  policy_arn = aws_iam_policy.controller_logs.arn
}

resource "aws_iam_role_policy" "controller" {
  name   = local.iam_controller_policy_name
  role   = aws_iam_role.controller.id
  policy = data.aws_iam_policy_document.controller.json
}

resource "aws_iam_role_policy" "controller_processor_logs" {
  name   = local.iam_controller_processor_logs_policy_name
  role   = aws_iam_role.controller.id
  policy = data.aws_iam_policy_document.controller_processor_logs.json
}
