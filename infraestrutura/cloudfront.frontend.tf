resource "aws_cloudfront_origin_access_control" "frontend" {
  name                              = local.cloudfront_frontend_origin_access_name
  description                       = var.cloudfront_frontend_origin_access_control_description
  origin_access_control_origin_type = var.cloudfront_frontend_origin_access_control_origin_type
  signing_behavior                  = var.cloudfront_frontend_origin_access_control_signing_behavior
  signing_protocol                  = var.cloudfront_frontend_origin_access_control_signing_protocol
}

resource "aws_cloudfront_distribution" "frontend" {
  comment             = local.cloudfront_frontend_name
  enabled             = var.cloudfront_frontend_enabled
  is_ipv6_enabled     = var.cloudfront_frontend_ipv6_enabled
  http_version        = var.cloudfront_frontend_http_version
  price_class         = var.cloudfront_frontend_price_class
  default_root_object = var.cloudfront_frontend_default_root_object

  origin {
    origin_id                = local.cloudfront_frontend_origin_id
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend.id
  }

  default_cache_behavior {
    target_origin_id       = local.cloudfront_frontend_origin_id
    viewer_protocol_policy = var.cloudfront_frontend_viewer_protocol_policy
    allowed_methods        = var.cloudfront_frontend_allowed_methods
    cached_methods         = var.cloudfront_frontend_cached_methods
    compress               = var.cloudfront_frontend_compress_enabled
    cache_policy_id        = var.cloudfront_frontend_cache_policy_id
  }

  restrictions {
    geo_restriction {
      restriction_type = var.cloudfront_frontend_geo_restriction_type
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = local.cloudfront_frontend_name
  }
}
