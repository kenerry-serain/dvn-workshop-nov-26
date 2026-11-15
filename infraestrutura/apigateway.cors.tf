# OPTIONS (CORS, integração MOCK) nas quatro rotas.

locals {
  api_gateway_cors_resources = {
    orders       = aws_api_gateway_resource.orders.id
    orders_batch = aws_api_gateway_resource.orders_batch.id
    runs         = aws_api_gateway_resource.runs.id
    run          = aws_api_gateway_resource.run.id
  }
}

resource "aws_api_gateway_method" "cors" {
  for_each = local.api_gateway_cors_resources

  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = each.value
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

resource "aws_api_gateway_method_response" "cors" {
  for_each = local.api_gateway_cors_resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = "200"

  response_models = {
    (var.api_gateway_content_type) = var.api_gateway_empty_model_name
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin"  = false
  }
}

resource "aws_api_gateway_integration" "cors" {
  for_each = local.api_gateway_cors_resources

  rest_api_id          = aws_api_gateway_rest_api.this.id
  resource_id          = each.value
  http_method          = aws_api_gateway_method.cors[each.key].http_method
  type                 = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"
  timeout_milliseconds = var.api_gateway_integration_timeout_milliseconds

  request_templates = {
    (var.api_gateway_content_type) = chomp(file("${path.module}/${var.api_templates_dir}/${var.api_gateway_cors_request_template_file}"))
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  for_each = local.api_gateway_cors_resources

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value
  http_method = aws_api_gateway_method.cors[each.key].http_method
  status_code = aws_api_gateway_method_response.cors[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = var.api_gateway_cors_allow_headers
    "method.response.header.Access-Control-Allow-Methods" = var.api_gateway_cors_allow_methods
    "method.response.header.Access-Control-Allow-Origin"  = var.api_gateway_cors_allow_origin
  }

  depends_on = [aws_api_gateway_integration.cors]
}
