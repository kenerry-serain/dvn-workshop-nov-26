# Role da Lambda processor: consome a fila e grava no DynamoDB.

data "aws_iam_policy_document" "processor_logs" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = [local.cloudwatch_logs_wildcard_arn]
  }

  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.processor.arn}:*"]
  }
}

data "aws_iam_policy_document" "processor" {
  statement {
    sid = "Dynamodb"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
    ]
    resources = [aws_dynamodb_table.orders.arn]
  }

  statement {
    sid = "ConsumeQueue"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
    ]
    resources = [aws_sqs_queue.orders.arn]
  }
}

resource "aws_iam_role" "processor" {
  name               = local.iam_processor_role_name
  path               = var.iam_lambda_role_path
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "processor_logs" {
  name   = local.iam_processor_logs_policy_name
  path   = var.iam_lambda_role_path
  policy = data.aws_iam_policy_document.processor_logs.json
}

resource "aws_iam_role_policy_attachment" "processor_logs" {
  role       = aws_iam_role.processor.name
  policy_arn = aws_iam_policy.processor_logs.arn
}

resource "aws_iam_role_policy" "processor" {
  name   = local.iam_processor_policy_name
  role   = aws_iam_role.processor.id
  policy = data.aws_iam_policy_document.processor.json
}
