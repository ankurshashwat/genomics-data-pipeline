variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN of the Lambda IAM role"
}

variable "input_bucket_name" {
  type        = string
  description = "Name of the input S3 bucket (with suffix)"
}

variable "output_bucket_name" {
  type        = string
  description = "Name of the output S3 bucket (with suffix)"
}

variable "glue_job_name" {
  type        = string
  description = "Name of the Glue job"
}