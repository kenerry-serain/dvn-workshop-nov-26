resource "aws_dynamodb_table" "orders" {
  name                        = local.dynamodb_table_name
  billing_mode                = var.dynamodb_table_billing_mode
  table_class                 = var.dynamodb_table_class
  hash_key                    = var.dynamodb_table_hash_key_name
  range_key                   = var.dynamodb_table_range_key_name
  deletion_protection_enabled = var.dynamodb_table_deletion_protection_enabled

  attribute {
    name = var.dynamodb_table_hash_key_name
    type = var.dynamodb_table_hash_key_type
  }

  attribute {
    name = var.dynamodb_table_range_key_name
    type = var.dynamodb_table_range_key_type
  }

  ttl {
    attribute_name = var.dynamodb_table_ttl_attribute_name
    enabled        = var.dynamodb_table_ttl_enabled
  }

  point_in_time_recovery {
    enabled = var.dynamodb_table_point_in_time_recovery_enabled
  }

  on_demand_throughput {
    max_read_request_units  = var.dynamodb_table_max_read_request_units
    max_write_request_units = var.dynamodb_table_max_write_request_units
  }
}
