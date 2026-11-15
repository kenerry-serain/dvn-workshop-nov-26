# -----------------------------------------------------------------------------
# Geral
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Prefixo usado no nome de todos os recursos (valores com hífen, em minúsculas)."
  type        = string
  default     = "live-infra-system-design"

  validation {
    condition     = can(regex("^[a-z0-9]+(-[a-z0-9]+)*$", var.project_name))
    error_message = "project_name deve ter apenas letras minúsculas, números e hífens."
  }
}

variable "aws_region" {
  description = "Região da AWS onde a infraestrutura é criada."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags aplicadas a todos os recursos pelo provider (default_tags)."
  type        = map(string)
  default = {
    Project   = "live-system-design"
    ManagedBy = "terraform"
  }
}

variable "lambda_packages_dir" {
  description = "Diretório, relativo a este módulo, com os pacotes .zip das Lambdas."
  type        = string
  default     = "lambda-packages"
}

variable "api_models_dir" {
  description = "Diretório, relativo a este módulo, com os JSON Schemas dos models do API Gateway."
  type        = string
  default     = "api-models"
}

variable "api_templates_dir" {
  description = "Diretório, relativo a este módulo, com os mapping templates (VTL/JSON) do API Gateway."
  type        = string
  default     = "api-templates"
}

# -----------------------------------------------------------------------------
# DynamoDB
# -----------------------------------------------------------------------------

variable "dynamodb_table_name_suffix" {
  description = "Sufixo do nome da tabela, concatenado a project_name."
  type        = string
  default     = "dynamodb-table"
}

variable "dynamodb_table_billing_mode" {
  description = "Modo de cobrança da tabela (PROVISIONED ou PAY_PER_REQUEST)."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_table_class" {
  description = "Classe de armazenamento da tabela (STANDARD ou STANDARD_INFREQUENT_ACCESS)."
  type        = string
  default     = "STANDARD"
}

variable "dynamodb_table_hash_key_name" {
  description = "Nome do atributo da partition key."
  type        = string
  default     = "pk"
}

variable "dynamodb_table_hash_key_type" {
  description = "Tipo do atributo da partition key (S, N ou B)."
  type        = string
  default     = "S"
}

variable "dynamodb_table_range_key_name" {
  description = "Nome do atributo da sort key."
  type        = string
  default     = "sk"
}

variable "dynamodb_table_range_key_type" {
  description = "Tipo do atributo da sort key (S, N ou B)."
  type        = string
  default     = "S"
}

variable "dynamodb_table_ttl_attribute_name" {
  description = "Nome do atributo usado como TTL."
  type        = string
  default     = "ttl"
}

variable "dynamodb_table_ttl_enabled" {
  description = "Habilita a expiração de itens por TTL."
  type        = bool
  default     = true
}

variable "dynamodb_table_max_read_request_units" {
  description = "Teto de unidades de leitura por segundo no modo on-demand."
  type        = number
  default     = 4000
}

variable "dynamodb_table_max_write_request_units" {
  description = "Teto de unidades de escrita por segundo no modo on-demand."
  type        = number
  default     = 4000
}

variable "dynamodb_table_point_in_time_recovery_enabled" {
  description = "Habilita o point-in-time recovery da tabela."
  type        = bool
  default     = false
}

variable "dynamodb_table_deletion_protection_enabled" {
  description = "Habilita a proteção contra exclusão da tabela."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# SQS
# -----------------------------------------------------------------------------

variable "sqs_fifo_queue_enabled" {
  description = "Cria as filas como FIFO (o nome precisa terminar em .fifo)."
  type        = bool
  default     = true
}

variable "sqs_content_based_deduplication_enabled" {
  description = "Habilita a deduplicação baseada no conteúdo das mensagens."
  type        = bool
  default     = false
}

variable "sqs_managed_sse_enabled" {
  description = "Habilita a criptografia em repouso gerenciada pelo SQS."
  type        = bool
  default     = true
}

variable "sqs_orders_queue_name_suffix" {
  description = "Sufixo do nome da fila principal de pedidos, concatenado a project_name."
  type        = string
  default     = "pedidos-queue.fifo"
}

variable "sqs_orders_queue_visibility_timeout_seconds" {
  description = "Timeout de visibilidade da fila principal, em segundos."
  type        = number
  default     = 60
}

variable "sqs_orders_queue_message_retention_seconds" {
  description = "Retenção das mensagens da fila principal, em segundos."
  type        = number
  default     = 345600
}

variable "sqs_orders_queue_max_message_size" {
  description = "Tamanho máximo de mensagem da fila principal, em bytes."
  type        = number
  default     = 1048576
}

variable "sqs_orders_queue_deduplication_scope" {
  description = "Escopo da deduplicação da fila principal (messageGroup ou queue)."
  type        = string
  default     = "messageGroup"
}

variable "sqs_orders_queue_fifo_throughput_limit" {
  description = "Limite de throughput FIFO da fila principal (perQueue ou perMessageGroupId)."
  type        = string
  default     = "perMessageGroupId"
}

variable "sqs_orders_queue_max_receive_count" {
  description = "Quantas vezes uma mensagem é recebida antes de ir para a DLQ."
  type        = number
  default     = 5
}

variable "sqs_dlq_name_suffix" {
  description = "Sufixo do nome da DLQ, concatenado a project_name."
  type        = string
  default     = "pedidos-queue-dlq.fifo"
}

variable "sqs_dlq_visibility_timeout_seconds" {
  description = "Timeout de visibilidade da DLQ, em segundos."
  type        = number
  default     = 30
}

variable "sqs_dlq_message_retention_seconds" {
  description = "Retenção das mensagens da DLQ, em segundos."
  type        = number
  default     = 345600
}

variable "sqs_dlq_max_message_size" {
  description = "Tamanho máximo de mensagem da DLQ, em bytes."
  type        = number
  default     = 1048576
}

variable "sqs_dlq_deduplication_scope" {
  description = "Escopo da deduplicação da DLQ (messageGroup ou queue)."
  type        = string
  default     = "queue"
}

variable "sqs_dlq_fifo_throughput_limit" {
  description = "Limite de throughput FIFO da DLQ (perQueue ou perMessageGroupId)."
  type        = string
  default     = "perQueue"
}

variable "sqs_dlq_redrive_permission" {
  description = "Quais filas de origem podem usar a DLQ (allowAll, denyAll ou byQueue)."
  type        = string
  default     = "byQueue"
}

# -----------------------------------------------------------------------------
# CloudWatch Logs
# -----------------------------------------------------------------------------

variable "cloudwatch_log_group_name_prefix" {
  description = "Prefixo dos log groups das Lambdas, antes do nome da função."
  type        = string
  default     = "/aws/lambda"
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "Retenção dos logs em dias. Nulo mantém os logs para sempre."
  type        = number
  default     = null
}

# -----------------------------------------------------------------------------
# Lambda: configuração comum
# -----------------------------------------------------------------------------

variable "lambda_runtime" {
  description = "Runtime das três funções."
  type        = string
  default     = "nodejs26.x"
}

variable "lambda_architectures" {
  description = "Arquiteturas de CPU das funções."
  type        = list(string)
  default     = ["x86_64"]
}

variable "lambda_ephemeral_storage_size" {
  description = "Tamanho do /tmp das funções, em MB."
  type        = number
  default     = 512
}

variable "lambda_tracing_mode" {
  description = "Modo do X-Ray das funções (PassThrough ou Active)."
  type        = string
  default     = "PassThrough"
}

variable "lambda_log_format" {
  description = "Formato dos logs das funções (Text ou JSON)."
  type        = string
  default     = "Text"
}

variable "lambda_invoke_action" {
  description = "Ação concedida ao API Gateway na resource policy da Lambda controller."
  type        = string
  default     = "lambda:InvokeFunction"
}

# -----------------------------------------------------------------------------
# Lambda: controller
# -----------------------------------------------------------------------------

variable "lambda_controller_name_suffix" {
  description = "Sufixo do nome da função controller, concatenado a project_name."
  type        = string
  default     = "controller-lambda"
}

variable "lambda_controller_handler" {
  description = "Handler da função controller."
  type        = string
  default     = "lambda-controller/control.handler"
}

variable "lambda_controller_package_file" {
  description = "Nome do .zip da função controller dentro de lambda_packages_dir."
  type        = string
  default     = "controller.zip"
}

variable "lambda_controller_timeout" {
  description = "Timeout da função controller, em segundos."
  type        = number
  default     = 180
}

variable "lambda_controller_memory_size" {
  description = "Memória da função controller, em MB."
  type        = number
  default     = 512
}

variable "lambda_controller_permission_statement_id_prefix" {
  description = "Prefixo do statement id das permissões de invocação do API Gateway na controller."
  type        = string
  default     = "AllowAPIGatewayInvoke"
}

# -----------------------------------------------------------------------------
# Lambda: generator
# -----------------------------------------------------------------------------

variable "lambda_generator_name_suffix" {
  description = "Sufixo do nome da função generator, concatenado a project_name."
  type        = string
  default     = "generator-lambda"
}

variable "lambda_generator_handler" {
  description = "Handler da função generator."
  type        = string
  default     = "lambda-generator/generator.handler"
}

variable "lambda_generator_package_file" {
  description = "Nome do .zip da função generator dentro de lambda_packages_dir."
  type        = string
  default     = "generator.zip"
}

variable "lambda_generator_timeout" {
  description = "Timeout da função generator, em segundos."
  type        = number
  default     = 183
}

variable "lambda_generator_memory_size" {
  description = "Memória da função generator, em MB."
  type        = number
  default     = 512
}

# -----------------------------------------------------------------------------
# Lambda: processor
# -----------------------------------------------------------------------------

variable "lambda_processor_name_suffix" {
  description = "Sufixo do nome da função processor, concatenado a project_name."
  type        = string
  default     = "processor-lambda"
}

variable "lambda_processor_handler" {
  description = "Handler da função processor."
  type        = string
  default     = "lambda-processor/processor.handler"
}

variable "lambda_processor_package_file" {
  description = "Nome do .zip da função processor dentro de lambda_packages_dir."
  type        = string
  default     = "processor.zip"
}

variable "lambda_processor_timeout" {
  description = "Timeout da função processor, em segundos."
  type        = number
  default     = 10
}

variable "lambda_processor_memory_size" {
  description = "Memória da função processor, em MB."
  type        = number
  default     = 128
}

variable "lambda_processor_event_source_mapping_enabled" {
  description = "Habilita o trigger SQS da função processor."
  type        = bool
  default     = true
}

variable "lambda_processor_batch_size" {
  description = "Quantidade máxima de mensagens por invocação do processor."
  type        = number
  default     = 10
}

variable "lambda_processor_maximum_batching_window_in_seconds" {
  description = "Tempo máximo, em segundos, juntando mensagens antes de invocar o processor."
  type        = number
  default     = 0
}

variable "lambda_processor_function_response_types" {
  description = "Tipos de resposta do trigger SQS (ReportBatchItemFailures permite falha parcial do lote)."
  type        = list(string)
  default     = ["ReportBatchItemFailures"]
}

# -----------------------------------------------------------------------------
# IAM
# -----------------------------------------------------------------------------

variable "iam_lambda_service_principal" {
  description = "Service principal que assume as roles das Lambdas."
  type        = string
  default     = "lambda.amazonaws.com"
}

variable "iam_api_gateway_service_principal" {
  description = "Service principal do API Gateway (assume a role de acesso ao SQS e invoca a Lambda)."
  type        = string
  default     = "apigateway.amazonaws.com"
}

variable "iam_cloudfront_service_principal" {
  description = "Service principal do CloudFront (lê o bucket do frontend)."
  type        = string
  default     = "cloudfront.amazonaws.com"
}

variable "iam_lambda_role_path" {
  description = "Path das roles e policies das Lambdas."
  type        = string
  default     = "/service-role/"
}

variable "iam_sqs_role_path" {
  description = "Path da role usada pelo API Gateway para acessar o SQS."
  type        = string
  default     = "/"
}

variable "iam_sqs_role_name_suffix" {
  description = "Sufixo do nome da role do API Gateway, concatenado a project_name."
  type        = string
  default     = "api-gateway-role"
}

variable "iam_sqs_role_description" {
  description = "Descrição da role do API Gateway."
  type        = string
  default     = "Allows API Gateway to push logs to CloudWatch Logs and send messages to SQS."
}

variable "iam_sqs_role_managed_policy_arns" {
  description = "ARNs das policies gerenciadas anexadas à role do API Gateway."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
}

variable "iam_sqs_role_policy_name_suffix" {
  description = "Sufixo do nome da inline policy (sqs:SendMessage) da role do API Gateway."
  type        = string
  default     = "api-gateway-inline-policy"
}

variable "iam_controller_role_name_suffix" {
  description = "Sufixo do nome da role da Lambda controller."
  type        = string
  default     = "controller-lambda-role"
}

variable "iam_controller_logs_policy_name_suffix" {
  description = "Sufixo do nome da policy de logs da Lambda controller."
  type        = string
  default     = "controller-lambda-logs-policy"
}

variable "iam_controller_policy_name_suffix" {
  description = "Sufixo do nome da inline policy (DynamoDB, SQS e invoke) da Lambda controller."
  type        = string
  default     = "controller-inline-policy"
}

variable "iam_controller_processor_logs_policy_name_suffix" {
  description = "Sufixo do nome da inline policy que permite à controller ler os logs do processor."
  type        = string
  default     = "controller-read-processor-logs-policy"
}

variable "iam_generator_role_name_suffix" {
  description = "Sufixo do nome da role da Lambda generator."
  type        = string
  default     = "generator-lambda-role"
}

variable "iam_generator_logs_policy_name_suffix" {
  description = "Sufixo do nome da policy de logs da Lambda generator."
  type        = string
  default     = "generator-lambda-logs-policy"
}

variable "iam_generator_policy_name_suffix" {
  description = "Sufixo do nome da inline policy (DynamoDB) da Lambda generator."
  type        = string
  default     = "generator-inline-policy"
}

variable "iam_processor_role_name_suffix" {
  description = "Sufixo do nome da role da Lambda processor."
  type        = string
  default     = "processor-lambda-role"
}

variable "iam_processor_logs_policy_name_suffix" {
  description = "Sufixo do nome da policy de logs da Lambda processor."
  type        = string
  default     = "processor-lambda-logs-policy"
}

variable "iam_processor_policy_name_suffix" {
  description = "Sufixo do nome da inline policy (DynamoDB e SQS) da Lambda processor."
  type        = string
  default     = "processor-inline-policy"
}

# -----------------------------------------------------------------------------
# API Gateway
# -----------------------------------------------------------------------------

variable "api_gateway_name_suffix" {
  description = "Sufixo do nome da REST API, concatenado a project_name."
  type        = string
  default     = "api"
}

variable "api_gateway_api_key_source" {
  description = "Origem da API key nas requisições (HEADER ou AUTHORIZER)."
  type        = string
  default     = "HEADER"
}

variable "api_gateway_endpoint_types" {
  description = "Tipos de endpoint da REST API (EDGE, REGIONAL ou PRIVATE)."
  type        = list(string)
  default     = ["REGIONAL"]
}

variable "api_gateway_ip_address_type" {
  description = "Tipo de endereço IP do endpoint (ipv4 ou dualstack)."
  type        = string
  default     = "ipv4"
}

variable "api_gateway_security_policy" {
  description = "Política de TLS do endpoint da REST API."
  type        = string
  default     = "TLS_1_0"
}

variable "api_gateway_disable_execute_api_endpoint" {
  description = "Desabilita o endpoint padrão execute-api."
  type        = bool
  default     = false
}

variable "api_gateway_stage_name" {
  description = "Nome do stage publicado."
  type        = string
  default     = "live"
}

variable "api_gateway_cache_cluster_enabled" {
  description = "Habilita o cache do stage."
  type        = bool
  default     = false
}

variable "api_gateway_xray_tracing_enabled" {
  description = "Habilita o X-Ray no stage."
  type        = bool
  default     = false
}

variable "api_gateway_integration_timeout_milliseconds" {
  description = "Timeout das integrações, em milissegundos (máximo de 29000)."
  type        = number
  default     = 29000
}

variable "api_gateway_content_type" {
  description = "Content-Type usado nos models e nos templates de requisição e resposta."
  type        = string
  default     = "application/json"
}

variable "api_gateway_empty_model_name" {
  description = "Nome do model padrão vazio, criado pelo próprio API Gateway."
  type        = string
  default     = "Empty"
}

variable "api_gateway_order_model_name" {
  description = "Nome do model do corpo de POST /orders."
  type        = string
  default     = "Order"
}

variable "api_gateway_order_model_schema_file" {
  description = "Arquivo, dentro de api_models_dir, com o JSON Schema do model de pedido."
  type        = string
  default     = "order.json"
}

variable "api_gateway_order_batch_model_name" {
  description = "Nome do model do corpo de POST /orders/batch."
  type        = string
  default     = "OrderBatch"
}

variable "api_gateway_order_batch_model_schema_file" {
  description = "Arquivo, dentro de api_models_dir, com o JSON Schema do model de lote de pedidos."
  type        = string
  default     = "order-batch.json"
}

variable "api_gateway_orders_path_part" {
  description = "Segmento de path da rota de pedidos."
  type        = string
  default     = "orders"
}

variable "api_gateway_orders_batch_path_part" {
  description = "Segmento de path da rota de lote de pedidos, filha de orders."
  type        = string
  default     = "batch"
}

variable "api_gateway_runs_path_part" {
  description = "Segmento de path da rota de execuções."
  type        = string
  default     = "runs"
}

variable "api_gateway_run_path_part" {
  description = "Segmento de path (com path parameter entre chaves) de uma execução, filha de runs."
  type        = string
  default     = "{runId}"
}

variable "api_gateway_cors_allow_headers" {
  description = "Valor do header Access-Control-Allow-Headers (com aspas simples, como exige o API Gateway)."
  type        = string
  default     = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
}

variable "api_gateway_cors_allow_methods" {
  description = "Valor do header Access-Control-Allow-Methods (com aspas simples, como exige o API Gateway)."
  type        = string
  default     = "'OPTIONS'"
}

variable "api_gateway_cors_allow_origin" {
  description = "Valor do header Access-Control-Allow-Origin (com aspas simples, como exige o API Gateway)."
  type        = string
  default     = "'*'"
}

variable "api_gateway_cors_request_template_file" {
  description = "Arquivo, dentro de api_templates_dir, com o template da integração MOCK do OPTIONS."
  type        = string
  default     = "cors-request.json"
}

variable "api_gateway_orders_request_template_file" {
  description = "Arquivo, dentro de api_templates_dir, que converte POST /orders em SendMessage do SQS."
  type        = string
  default     = "orders-request.vtl"
}

variable "api_gateway_orders_accepted_template_file" {
  description = "Arquivo, dentro de api_templates_dir, com a resposta 202 de POST /orders."
  type        = string
  default     = "orders-accepted.vtl"
}

variable "api_gateway_orders_accepted_selection_pattern" {
  description = "Regex da resposta do SQS que vira 202 em POST /orders."
  type        = string
  default     = "^200$"
}

variable "api_gateway_orders_rejected_template_file" {
  description = "Arquivo, dentro de api_templates_dir, com a resposta 400/429 de POST /orders."
  type        = string
  default     = "orders-rejected.vtl"
}

variable "api_gateway_orders_rejected_selection_pattern" {
  description = "Regex da resposta do SQS que vira 400 (ou 429, no throttling) em POST /orders."
  type        = string
  default     = "^4\\d{2}$"
}

variable "api_gateway_orders_unavailable_template_file" {
  description = "Arquivo, dentro de api_templates_dir, com a resposta 500 de POST /orders."
  type        = string
  default     = "orders-unavailable.vtl"
}

variable "api_gateway_orders_batch_request_template_file" {
  description = "Arquivo, dentro de api_templates_dir, que converte POST /orders/batch em SendMessageBatch do SQS."
  type        = string
  default     = "orders-batch-request.vtl"
}

variable "api_gateway_orders_batch_response_template_file" {
  description = "Arquivo, dentro de api_templates_dir, com a resposta de POST /orders/batch."
  type        = string
  default     = "orders-batch-response.vtl"
}

variable "api_gateway_sqs_send_message_batch_target" {
  description = "Valor do header X-Amz-Target da operação SendMessageBatch (com aspas simples)."
  type        = string
  default     = "'AmazonSQS.SendMessageBatch'"
}

variable "api_gateway_sqs_send_message_content_type" {
  description = "Content-Type (com aspas simples) da chamada SendMessage ao SQS."
  type        = string
  default     = "'application/x-www-form-urlencoded'"
}

variable "api_gateway_sqs_send_message_batch_content_type" {
  description = "Content-Type (com aspas simples) da chamada SendMessageBatch ao SQS."
  type        = string
  default     = "'application/x-amz-json-1.0'"
}

variable "api_gateway_api_key_name_suffix" {
  description = "Sufixo do nome da API key, concatenado a project_name."
  type        = string
  default     = "api-key"
}

variable "api_gateway_api_key_enabled" {
  description = "Habilita a API key."
  type        = bool
  default     = true
}

variable "api_gateway_usage_plan_name_suffix" {
  description = "Sufixo do nome do usage plan, concatenado a project_name."
  type        = string
  default     = "usage-plan"
}

variable "api_gateway_usage_plan_burst_limit" {
  description = "Burst do usage plan, em requisições."
  type        = number
  default     = 600
}

variable "api_gateway_usage_plan_rate_limit" {
  description = "Taxa do usage plan, em requisições por segundo."
  type        = number
  default     = 3000
}

# -----------------------------------------------------------------------------
# Frontend: S3 e CloudFront
# -----------------------------------------------------------------------------

variable "s3_frontend_bucket_name_suffix" {
  description = "Sufixo do nome do bucket do frontend, concatenado a project_name."
  type        = string
  default     = "bucket"
}

variable "s3_frontend_object_ownership" {
  description = "Propriedade dos objetos do bucket do frontend."
  type        = string
  default     = "BucketOwnerEnforced"
}

variable "s3_frontend_sse_algorithm" {
  description = "Algoritmo de criptografia padrão do bucket do frontend (AES256 ou aws:kms)."
  type        = string
  default     = "AES256"
}

variable "s3_frontend_bucket_key_enabled" {
  description = "Habilita o S3 Bucket Key na criptografia do bucket do frontend."
  type        = bool
  default     = true
}

variable "s3_frontend_block_public_access_enabled" {
  description = "Bloqueia todo acesso público ao bucket do frontend."
  type        = bool
  default     = true
}

variable "s3_frontend_bucket_policy_statement_sid" {
  description = "Sid do statement que libera a leitura do bucket para o CloudFront."
  type        = string
  default     = "AllowCloudFrontServicePrincipal"
}

variable "cloudfront_frontend_name_suffix" {
  description = "Sufixo do nome (tag Name e comentário) da distribuição, concatenado a project_name."
  type        = string
  default     = "distribution"
}

variable "cloudfront_frontend_origin_access_control_name_suffix" {
  description = "Sufixo do nome do origin access control, concatenado a project_name."
  type        = string
  default     = "oac"
}

variable "cloudfront_frontend_origin_access_control_description" {
  description = "Descrição do origin access control."
  type        = string
  default     = "Acesso do CloudFront ao bucket do frontend."
}

variable "cloudfront_frontend_origin_access_control_origin_type" {
  description = "Tipo de origem do origin access control."
  type        = string
  default     = "s3"
}

variable "cloudfront_frontend_origin_access_control_signing_behavior" {
  description = "Quando o CloudFront assina as requisições à origem (always, never ou no-override)."
  type        = string
  default     = "always"
}

variable "cloudfront_frontend_origin_access_control_signing_protocol" {
  description = "Protocolo de assinatura das requisições à origem."
  type        = string
  default     = "sigv4"
}

variable "cloudfront_frontend_enabled" {
  description = "Habilita a distribuição."
  type        = bool
  default     = true
}

variable "cloudfront_frontend_ipv6_enabled" {
  description = "Habilita IPv6 na distribuição."
  type        = bool
  default     = true
}

variable "cloudfront_frontend_http_version" {
  description = "Versão máxima do HTTP aceita pela distribuição."
  type        = string
  default     = "http2"
}

variable "cloudfront_frontend_price_class" {
  description = "Classe de preço da distribuição."
  type        = string
  default     = "PriceClass_All"
}

variable "cloudfront_frontend_default_root_object" {
  description = "Objeto servido na raiz da distribuição."
  type        = string
  default     = "index.html"
}

variable "cloudfront_frontend_viewer_protocol_policy" {
  description = "Política de protocolo do viewer (allow-all, https-only ou redirect-to-https)."
  type        = string
  default     = "redirect-to-https"
}

variable "cloudfront_frontend_allowed_methods" {
  description = "Métodos HTTP aceitos pela distribuição."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cloudfront_frontend_cached_methods" {
  description = "Métodos HTTP cujas respostas são cacheadas."
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "cloudfront_frontend_compress_enabled" {
  description = "Habilita a compressão automática das respostas."
  type        = bool
  default     = true
}

variable "cloudfront_frontend_cache_policy_id" {
  description = "ID da cache policy (o default é a gerenciada Managed-CachingOptimized)."
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "cloudfront_frontend_geo_restriction_type" {
  description = "Tipo de restrição geográfica (none, whitelist ou blacklist)."
  type        = string
  default     = "none"
}
