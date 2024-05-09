output dynamodb_table_arn {
  description = "ARN of the existing DynamoDB table"
  value       = module.dynamodb_table.dynamodb_table_arn
}