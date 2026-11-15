resource "aws_api_gateway_rest_api" "this" {
  name                         = local.api_gateway_name
  api_key_source               = var.api_gateway_api_key_source
  security_policy              = var.api_gateway_security_policy
  disable_execute_api_endpoint = var.api_gateway_disable_execute_api_endpoint

  endpoint_configuration {
    types           = var.api_gateway_endpoint_types
    ip_address_type = var.api_gateway_ip_address_type
  }
}

# Models: validação do corpo das requisições de pedidos.

resource "aws_api_gateway_model" "order" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = var.api_gateway_order_model_name
  content_type = var.api_gateway_content_type
  schema       = chomp(file("${path.module}/${var.api_models_dir}/${var.api_gateway_order_model_schema_file}"))
}

resource "aws_api_gateway_model" "order_batch" {
  rest_api_id  = aws_api_gateway_rest_api.this.id
  name         = var.api_gateway_order_batch_model_name
  content_type = var.api_gateway_content_type
  schema       = chomp(file("${path.module}/${var.api_models_dir}/${var.api_gateway_order_batch_model_schema_file}"))
}

# Recursos (rotas): /orders, /orders/batch, /runs e /runs/{runId}.

resource "aws_api_gateway_resource" "orders" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.api_gateway_orders_path_part
}

resource "aws_api_gateway_resource" "orders_batch" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.orders.id
  path_part   = var.api_gateway_orders_batch_path_part
}

resource "aws_api_gateway_resource" "runs" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = var.api_gateway_runs_path_part
}

resource "aws_api_gateway_resource" "run" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.runs.id
  path_part   = var.api_gateway_run_path_part
}
