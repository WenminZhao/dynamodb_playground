output "assumable_iam_role" {
    description = "The name of the IAM role"
    value       = aws_iam_role.dax_service_role.arn
}

output "dax_iam_user" {
    description = "The IAM username"
    value       = aws_iam_user.dax_user.arn
}