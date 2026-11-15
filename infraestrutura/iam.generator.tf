# Role da Lambda generator: gera os pedidos de uma execução.

data "aws_iam_policy_document" "generator_logs" {
  statement {
    actions   = ["logs:CreateLogGroup"]
    resources = [local.cloudwatch_logs_wildcard_arn]
  }

  statement {
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.generator.arn}:*"]
  }
}

data "aws_iam_policy_document" "generator" {
  statement {
    sid       = "Dynamodb"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.orders.arn]
  }
}

resource "aws_iam_role" "generator" {
  name               = local.iam_generator_role_name
  path               = var.iam_lambda_role_path
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_policy" "generator_logs" {
  name   = local.iam_generator_logs_policy_name
  path   = var.iam_lambda_role_path
  policy = data.aws_iam_policy_document.generator_logs.json
}

resource "aws_iam_role_policy_attachment" "generator_logs" {
  role       = aws_iam_role.generator.name
  policy_arn = aws_iam_policy.generator_logs.arn
}

resource "aws_iam_role_policy" "generator" {
  name   = local.iam_generator_policy_name
  role   = aws_iam_role.generator.id
  policy = data.aws_iam_policy_document.generator.json
}
