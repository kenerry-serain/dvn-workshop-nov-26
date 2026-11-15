# POST /orders: API Gateway -> SQS (SendMessage), exige API key.

locals {
  api_gateway_orders_method_response_status_codes = toset(["200", "202", "400", "429", "500"])

  # Mapeia a resposta do SQS para a resposta HTTP da API.
  api_gateway_orders_integration_responses = {
    accepted = {
      status_code       = "202"
      selection_pattern = var.api_gateway_orders_accepted_selection_pattern
      template_file     = var.api_gateway_orders_accepted_template_file
    }
    rejected = {
      status_code       = "400"
      selection_pattern = var.api_gateway_orders_rejected_selection_pattern
      template_file     = var.api_gateway_orders_rejected_template_file
    }
    unavailable = {
      status_code       = "500"
      selection_pattern = null
      template_file     = var.api_gateway_orders_unavailable_template_file
    }
  }
}

resource "aws_api_gateway_method" "orders" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.orders.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

  request_models = {
    (var.api_gateway_content_type) = aws_api_gateway_model.order.name
  }
}

resource "aws_api_gateway_method_response" "orders" {
  for_each = local.api_gateway_orders_method_response_status_codes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders.id
  http_method = aws_api_gateway_method.orders.http_method
  status_code = each.key

  response_models = each.key == "200" ? { (var.api_gateway_content_type) = var.api_gateway_empty_model_name } : null

  response_parameters = each.key == "200" ? null : {
    "method.response.header.Access-Control-Allow-Origin" = false
  }
}

resource "aws_api_gateway_integration" "orders" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.orders.id
  http_method             = aws_api_gateway_method.orders.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = local.api_gateway_sqs_integration_uri
  credentials             = aws_iam_role.sqs.arn
  passthrough_behavior    = "NEVER"
  timeout_milliseconds    = var.api_gateway_integration_timeout_milliseconds

  request_parameters = {
    "integration.request.header.Content-Type" = var.api_gateway_sqs_send_message_content_type
  }

  request_templates = {
    (var.api_gateway_content_type) = chomp(file("${path.module}/${var.api_templates_dir}/${var.api_gateway_orders_request_template_file}"))
  }
}

resource "aws_api_gateway_integration_response" "orders" {
  for_each = local.api_gateway_orders_integration_responses

  rest_api_id       = aws_api_gateway_rest_api.this.id
  resource_id       = aws_api_gateway_resource.orders.id
  http_method       = aws_api_gateway_method.orders.http_method
  status_code       = aws_api_gateway_method_response.orders[each.value.status_code].status_code
  selection_pattern = each.value.selection_pattern

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = var.api_gateway_cors_allow_origin
  }

  response_templates = {
    (var.api_gateway_content_type) = chomp(file("${path.module}/${var.api_templates_dir}/${each.value.template_file}"))
  }

  depends_on = [aws_api_gateway_integration.orders]
}
