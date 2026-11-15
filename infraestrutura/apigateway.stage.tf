locals {
  # Entradas do hash de redeploy. Só valores de configuração e ids: objetos
  # inteiros trazem atributos que a API devolve normalizados depois do apply
  # e fariam o hash mudar a cada plan.
  api_gateway_redeployment_inputs = [
    aws_api_gateway_resource.orders.id,
    aws_api_gateway_resource.orders_batch.id,
    aws_api_gateway_resource.runs.id,
    aws_api_gateway_resource.run.id,
    local.api_gateway_cors_resources,
    local.api_gateway_runs_routes,
    local.api_gateway_orders_method_response_status_codes,
    local.api_gateway_orders_integration_responses,
    aws_api_gateway_integration.orders.request_templates,
    aws_api_gateway_integration.orders_batch.request_templates,
    aws_api_gateway_integration.orders.request_parameters,
    aws_api_gateway_integration.orders_batch.request_parameters,
    aws_api_gateway_integration.orders.uri,
    aws_api_gateway_integration.orders_batch.uri,
    aws_api_gateway_integration.runs["post_runs"].uri,
    { for key, response in aws_api_gateway_integration_response.orders : key => response.response_templates },
    aws_api_gateway_integration_response.orders_batch.response_templates,
    filesha1("${path.module}/${var.api_models_dir}/${var.api_gateway_order_model_schema_file}"),
    filesha1("${path.module}/${var.api_models_dir}/${var.api_gateway_order_batch_model_schema_file}"),
    var.api_gateway_content_type,
    var.api_gateway_cors_allow_headers,
    var.api_gateway_cors_allow_methods,
    var.api_gateway_cors_allow_origin,
  ]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Mudanças nas rotas, integrações ou models geram um novo deployment.
  triggers = {
    redeployment = sha1(jsonencode(local.api_gateway_redeployment_inputs))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  rest_api_id           = aws_api_gateway_rest_api.this.id
  deployment_id         = aws_api_gateway_deployment.this.id
  stage_name            = var.api_gateway_stage_name
  cache_cluster_enabled = var.api_gateway_cache_cluster_enabled
  xray_tracing_enabled  = var.api_gateway_xray_tracing_enabled
}
