output "lambda_function_arn" {
  value       = aws_lambda_function.validate_vcf.arn
  description = "ARN of the Lambda function"
}