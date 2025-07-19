output "input_bucket_name" {
  value       = module.s3.input_bucket_name
  description = "Name of the input S3 bucket"
}

output "output_bucket_name" {
  value       = module.s3.output_bucket_name
  description = "Name of the output S3 bucket"
}

output "lambda_function_arn" {
  value       = module.lambda.lambda_function_arn
  description = "ARN of the Lambda function"
}

output "glue_job_name" {
  value       = var.glue_job_name
  description = "Name of the Glue job"
}

output "athena_database_name" {
  value       = module.athena.athena_database_name
  description = "Name of the Athena database"
}