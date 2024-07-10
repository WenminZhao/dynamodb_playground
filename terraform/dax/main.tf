data "aws_dynamodb_table" "existing" {
  name = var.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the existing DynamoDB table"
  value       = data.aws_dynamodb_table.existing.arn
}



# create iam role, the role will have read and write access to the dynamodb table;
# the role will be assumable by the dax client
# we already have this role defined in dynamodb module, so we will reuse it here

# In AWS, a policy document is a formal specification of the permissions to be associated with an IAM entity (user, group, or role). 
# It is written in JSON format and defines what actions are allowed or denied on which AWS resources.
# data "aws_iam_policy_document" "dax_read_write_policy" {
#   statement {
#     actions = [
#       "dax:*" 
#     ]

#     resources = [data.aws_dynamodb_table.existing.arn]
#   }
# }

# create a role to access dax
# data "aws_iam_policy_document" "dynamodb_assumable" {
#   statement {
#     actions = [
#       "sts:AssumeRole"
#     ]
#     principals {
#       type        = "Service"
#       identifiers = ["dax.amazonaws.com"]
#     }
#   }
# }
# resource "aws_iam_role" "dax_assumable_role" {
#   name               = var.dax_assumable_iam_role_name
#   assume_role_policy = data.aws_iam_policy_document.dynamodb_assumable.json

# }

# resource "aws_iam_role_policy" "dynamodb_policy" {
#   name   = "FullAccessPolicyDax"
#   role   = aws_iam_role.dax_assumable_role.name
#   policy = data.aws_iam_policy_document.dax_read_write_policy.json
# }

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
  subnet_ids  = var.dax_subnet_id
  description = "DAX subnet group"
}

resource "aws_security_group" "this" {
  name        = "dax_security_group"
  description = "DAX security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8111
    to_port     = 8111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

   tags = {
    Name = "dax-security-group"
   } 
  }

resource "aws_dax_cluster" "this" {
  cluster_name         = var.dax_cluster_name
  node_type            = var.node_type
  replication_factor   = var.replication_factor
  subnet_group_name    = aws_dax_subnet_group.this.name
  security_group_ids =  [aws_security_group.this.id]
  parameter_group_name = aws_dax_parameter_group.this.name
  # the role we created in the iam module, which has access to dynamodb
  # and can be assumed
  iam_role_arn         = var.dax_assumable_iam_role_arn
  server_side_encryption {
    enabled = var.server_side_encryption
  }
}
