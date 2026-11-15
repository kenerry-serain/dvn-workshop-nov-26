data "aws_iam_policy_document" "frontend_bucket" {
  statement {
    sid       = var.s3_frontend_bucket_policy_statement_sid
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.frontend.arn}/*"]

    principals {
      type        = "Service"
      identifiers = [var.iam_cloudfront_service_principal]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.frontend.arn]
    }
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = local.s3_frontend_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    object_ownership = var.s3_frontend_object_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = var.s3_frontend_block_public_access_enabled
  ignore_public_acls      = var.s3_frontend_block_public_access_enabled
  block_public_policy     = var.s3_frontend_block_public_access_enabled
  restrict_public_buckets = var.s3_frontend_block_public_access_enabled
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  rule {
    bucket_key_enabled = var.s3_frontend_bucket_key_enabled

    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_frontend_sse_algorithm
    }
  }
}

# Só a distribuição do frontend pode ler objetos do bucket.
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  policy = data.aws_iam_policy_document.frontend_bucket.json

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}
