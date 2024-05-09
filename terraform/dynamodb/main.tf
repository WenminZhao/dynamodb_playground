# create table
module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name           = var.name
  hash_key       = var.pk
  range_key      = var.sk
  read_capacity  = var.billing_mode == "PAY_PER_REQUEST" ? null : var.read_capacity
  write_capacity = var.billing_mode == "PAY_PER_REQUEST" ? null : var.write_capacity
  table_class    = var.table_class
  ttl_enabled = var.ttl_enabled
  ttl_attribute_name = var.ttl_attribute_name

  attributes = [
    {
      name = "pk",
      type = "S"
    },
    {
      name = "sk",
      type = "S"
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}

# create a role for dynamodb
data "aws_iam_policy_document" "dynamodb_read_write_policy" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:BatchGetItem",
      "dynamodb:Query",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem"
    ]

    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
}

resource "aws_iam_role" "dynamodbrw_role" {
  name = var.dynamodb_rw_access_role_name
  assume_role_policy = data.aws_iam_policy
}