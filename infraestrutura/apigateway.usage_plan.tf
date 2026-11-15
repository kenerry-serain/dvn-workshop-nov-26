# API key e usage plan que controlam o acesso às rotas com api_key_required.

resource "aws_api_gateway_api_key" "this" {
  name    = local.api_gateway_api_key_name
  enabled = var.api_gateway_api_key_enabled
}

resource "aws_api_gateway_usage_plan" "this" {
  name = local.api_gateway_usage_plan_name

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  throttle_settings {
    burst_limit = var.api_gateway_usage_plan_burst_limit
    rate_limit  = var.api_gateway_usage_plan_rate_limit
  }
}

resource "aws_api_gateway_usage_plan_key" "this" {
  key_id        = aws_api_gateway_api_key.this.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this.id
}
