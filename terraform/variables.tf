variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "input_bucket_name" {
  type        = string
  description = "Name of the input S3 bucket (without suffix)"
}

variable "output_bucket_name" {
  type        = string
  description = "Name of the output S3 bucket (without suffix)"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "lambda_role_name" {
  type        = string
  description = "Name of the IAM role for Lambda"
}

variable "glue_role_name" {
  type        = string
  description = "Name of the IAM role for Glue"
}

variable "glue_job_name" {
  type        = string
  description = "Name of the Glue job"
}