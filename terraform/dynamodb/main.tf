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
data "aws_iam_policy_document" "dynamodb_read_write_policy_document" {
  statement {
    actions = [
      "dynamodb:*"
    ]
    effect = "Allow"
    resources = [module.dynamodb_table.dynamodb_table_arn]
  }
}

data "aws_iam_policy_document" "dynamodb_assumable_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "dynamodb_rw_policy" {
  name = "dynamodb_rw_policy"
  policy = data.aws_iam_policy_document.dynamodb_read_write_policy_document.json
}

resource "aws_iam_role" "dynamodbrw_role" {
  name = var.dynamodb_rw_access_role_name
  assume_role_policy = data.aws_iam_policy_document.dynamodb_assumable_role.json
}

resource "aws_iam_role_policy_attachment" "dynamodb_rw_policy_attachment" {
  role = aws_iam_role.dynamodbrw_role.name
  policy_arn = aws_iam_policy.dynamodb_rw_policy.arn
}