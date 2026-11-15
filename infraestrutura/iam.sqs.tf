# Role assumida pelo API Gateway para enviar pedidos ao SQS e publicar logs.

data "aws_iam_policy_document" "sqs_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [var.iam_api_gateway_service_principal]
    }
  }
}

data "aws_iam_policy_document" "sqs" {
  statement {
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.orders.arn]
  }
}

resource "aws_iam_role" "sqs" {
  name               = local.iam_sqs_role_name
  path               = var.iam_sqs_role_path
  description        = var.iam_sqs_role_description
  assume_role_policy = data.aws_iam_policy_document.sqs_assume_role.json
}

resource "aws_iam_role_policy_attachment" "sqs" {
  for_each = toset(var.iam_sqs_role_managed_policy_arns)

  role       = aws_iam_role.sqs.name
  policy_arn = each.value
}

resource "aws_iam_role_policy" "sqs" {
  name   = local.iam_sqs_role_policy_name
  role   = aws_iam_role.sqs.id
  policy = data.aws_iam_policy_document.sqs.json
}
