# Rotas da Lambda controller (proxy): POST /runs, GET /runs e GET /runs/{runId}.

locals {
  api_gateway_runs_routes = {
    post_runs = {
      resource_id        = aws_api_gateway_resource.runs.id
      http_method        = "POST"
      api_key_required   = true
      request_parameters = {}
      permission_path    = var.api_gateway_runs_path_part
    }
    get_runs = {
      resource_id        = aws_api_gateway_resource.runs.id
      http_method        = "GET"
      api_key_required   = false
      request_parameters = {}
      permission_path    = var.api_gateway_runs_path_part
    }
    get_run = {
      resource_id        = aws_api_gateway_resource.run.id
      http_method        = "GET"
      api_key_required   = true
      request_parameters = { "method.request.path.${local.api_gateway_run_path_parameter}" = true }
      permission_path    = "${var.api_gateway_runs_path_part}/*"
    }
  }
}

resource "aws_api_gateway_method" "runs" {
  for_each = local.api_gateway_runs_routes

  rest_api_id        = aws_api_gateway_rest_api.this.id
  resource_id        = each.value.resource_id
  http_method        = each.value.http_method
  authorization      = "NONE"
  api_key_required   = each.value.api_key_required
  request_parameters = each.value.request_parameters
}

resource "aws_api_gateway_method_response" "runs" {
  for_each = local.api_gateway_runs_routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_id
  http_method = aws_api_gateway_method.runs[each.key].http_method
  status_code = "200"

  response_models = {
    (var.api_gateway_content_type) = var.api_gateway_empty_model_name
  }
}

resource "aws_api_gateway_integration" "runs" {
  for_each = local.api_gateway_runs_routes

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = each.value.resource_id
  http_method             = aws_api_gateway_method.runs[each.key].http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.controller.invoke_arn
  passthrough_behavior    = "WHEN_NO_MATCH"
  content_handling        = "CONVERT_TO_TEXT"
  timeout_milliseconds    = var.api_gateway_integration_timeout_milliseconds
}

resource "aws_api_gateway_integration_response" "runs" {
  for_each = local.api_gateway_runs_routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = each.value.resource_id
  http_method = aws_api_gateway_method.runs[each.key].http_method
  status_code = aws_api_gateway_method_response.runs[each.key].status_code

  depends_on = [aws_api_gateway_integration.runs]
}
