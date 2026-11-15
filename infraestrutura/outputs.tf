output "api_gateway_stage_invoke_url" {
  description = "URL base do stage publicado da API."
  value       = aws_api_gateway_stage.this.invoke_url
}

output "api_gateway_rest_api_id" {
  description = "ID da REST API."
  value       = aws_api_gateway_rest_api.this.id
}

output "api_gateway_api_key_id" {
  description = "ID da API key (o valor é lido com `aws apigateway get-api-key --include-value`)."
  value       = aws_api_gateway_api_key.this.id
}

output "orders_dynamodb_table_name" {
  description = "Nome da tabela DynamoDB de pedidos."
  value       = aws_dynamodb_table.orders.name
}

output "orders_sqs_queue_url" {
  description = "URL da fila principal de pedidos."
  value       = aws_sqs_queue.orders.url
}

output "orders_dlq_sqs_queue_url" {
  description = "URL da DLQ de pedidos."
  value       = aws_sqs_queue.orders_dlq.url
}

output "lambda_function_names" {
  description = "Nomes das funções Lambda, por papel."
  value = {
    controller = aws_lambda_function.controller.function_name
    generator  = aws_lambda_function.generator.function_name
    processor  = aws_lambda_function.processor.function_name
  }
}

output "frontend_s3_bucket_id" {
  description = "Nome do bucket do frontend."
  value       = aws_s3_bucket.frontend.id
}

output "frontend_cloudfront_distribution_id" {
  description = "ID da distribuição do frontend (usado em invalidações de cache)."
  value       = aws_cloudfront_distribution.frontend.id
}

output "frontend_cloudfront_distribution_domain_name" {
  description = "Domínio da distribuição do frontend."
  value       = aws_cloudfront_distribution.frontend.domain_name
}
