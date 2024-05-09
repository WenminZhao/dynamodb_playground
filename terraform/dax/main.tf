data "aws_dynamodb_table" "existing" {
  name = var.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the existing DynamoDB table"
  value       = data.aws_dynamodb_table.existing.arn
}



# create iam role, the role will have read and write access to the dynamodb table;
# the role will be assumable by the dax client

# In AWS, a policy document is a formal specification of the permissions to be associated with an IAM entity (user, group, or role). 
# It is written in JSON format and defines what actions are allowed or denied on which AWS resources.
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

    resources = [data.aws_dynamodb_table.existing.arn]
  }
}

data "aws_iam_policy_document" "dynamodb_assumable" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["dax.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "dax_assumable_role" {
  name               = var.dax_assumable_iam_role_name
  assume_role_policy = data.aws_iam_policy_document.dynamodb_assumable.json

}

resource "aws_iam_role_policy" "dynamodb_policy" {
  name   = "FullAccessPolicyDynamoDB"
  role   = aws_iam_role.dax_assumable_role.name
  policy = data.aws_iam_policy_document.dynamodb_read_write_policy.json
}

resource "aws_dax_parameter_group" "this" {
  name        = var.parameter_group_name
  description = "DAX parameter group"
  parameters {
    name  = "query-ttl-millis"
    value = var.query_ttl_millis
  }

  parameters {
    name  = "record-ttl-millis"
    value = var.record_ttl_milli
  }
}

# create a subnet group
resource "aws_dax_subnet_group" "this" {
  name        = var.aws_dax_subnet_group_name
  subnet_ids  = [var.dax_subnet_id]
  description = "DAX subnet group"
}

# create dax cluster
resource "aws_dax_cluster" "this" {
  cluster_name         = var.dax_cluster_name
  node_type            = var.node_type
  replication_factor   = var.replication_factor
  subnet_group_name    = aws_dax_subnet_group.this.name
  parameter_group_name = aws_dax_parameter_group.this.name
  iam_role_arn         = aws_iam_role.dax_assumable_role.arn
  server_side_encryption {
    enabled = var.server_side_encryption
  }
}
