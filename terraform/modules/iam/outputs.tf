output "lambda_role_arn" {
  value       = aws_iam_role.lambda_role.arn
  description = "ARN of the Lambda IAM role"
}

output "glue_role_arn" {
  value       = aws_iam_role.glue_role.arn
  description = "ARN of the Glue IAM role"
}