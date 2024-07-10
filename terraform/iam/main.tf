# create an IAM user
resource "aws_iam_user" "dax_user" {
    name = var.dax_username
}

# create a iam service role to access dax cluster
# this role will be assumed by the iam user and access dax cluster
# this role will also be assumed by dax service and access dynamodb
resource "aws_iam_role" "dax_service_role" {
    name               = var.dax_assumable_iam_role_name 
    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "dax.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.dax_user.arn}"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# create a policy for dax to access dynamodb
data aws_iam_policy_document dax_read_write_policy {
    statement {
        actions = [
            "dynamodb:DescribeTable",
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
                "dynamodb:DeleteItem",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchGetItem",
                "dynamodb:BatchWriteItem",
                "dynamodb:ConditionCheckItem"
        ]
        effect = "Allow"
        resources = ["*"]
    }
}

resource "aws_iam_policy" "dynamodb_read_write_policy" {
    name        = "dynamodb_read_write_policy_for_dax"
    description = "Policy for DAX to access DynamoDB with full access"
    policy      = data.aws_iam_policy_document.dax_read_write_policy.json
}

resource "aws_iam_policy_attachment" "dax_read_write_policy_attachment" {
    name       = "dax_read_write_policy"
    roles      = [aws_iam_role.dax_service_role.name]
    policy_arn = aws_iam_policy.dynamodb_read_write_policy.arn
}

# create a policy for role to access dax
data aws_iam_policy_document dax_all_access {
    statement {
        actions = ["dax:*"]
        effect = "Allow"
        resources = ["*"]
    }
}

resource "aws_iam_policy" "dax_all_access_policy" {
    name        = "dax_all_access_policy"
    description = "Policy for DAX to access DynamoDB"
    policy      = data.aws_iam_policy_document.dax_all_access.json
}

resource "aws_iam_policy_attachment" "dax_all_access_policy_attachment" {
    name       = "dax_all_access_policy_attachment"
    roles      = [aws_iam_role.dax_service_role.name]
    policy_arn = aws_iam_policy.dax_all_access_policy.arn
}