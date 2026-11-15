# POST /orders/batch: API Gateway -> SQS (SendMessageBatch), exige API key.

resource "aws_api_gateway_method" "orders_batch" {
  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.orders_batch.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true

  request_models = {
    (var.api_gateway_content_type) = aws_api_gateway_model.order_batch.name
  }
}

resource "aws_api_gateway_method_response" "orders_batch" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders_batch.id
  http_method = aws_api_gateway_method.orders_batch.http_method
  status_code = "200"

  response_models = {
    (var.api_gateway_content_type) = var.api_gateway_empty_model_name
  }
}

resource "aws_api_gateway_integration" "orders_batch" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.orders_batch.id
  http_method             = aws_api_gateway_method.orders_batch.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = local.api_gateway_sqs_integration_uri
  credentials             = aws_iam_role.sqs.arn
  passthrough_behavior    = "NEVER"
  timeout_milliseconds    = var.api_gateway_integration_timeout_milliseconds

  request_parameters = {
    "integration.request.header.Content-Type" = var.api_gateway_sqs_send_message_batch_content_type
    "integration.request.header.X-Amz-Target" = var.api_gateway_sqs_send_message_batch_target
  }

  request_templates = {
    (var.api_gateway_content_type) = chomp(templatefile(
      "${path.module}/${var.api_templates_dir}/${var.api_gateway_orders_batch_request_template_file}",
      { queue_url = aws_sqs_queue.orders.url },
    ))
  }
}

resource "aws_api_gateway_integration_response" "orders_batch" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.orders_batch.id
  http_method = aws_api_gateway_method.orders_batch.http_method
  status_code = aws_api_gateway_method_response.orders_batch.status_code

  response_templates = {
    (var.api_gateway_content_type) = chomp(file("${path.module}/${var.api_templates_dir}/${var.api_gateway_orders_batch_response_template_file}"))
  }

  depends_on = [aws_api_gateway_integration.orders_batch]
}
