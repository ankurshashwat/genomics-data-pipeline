variable "lambda_role_name" {
  type        = string
  description = "Name of the IAM role for Lambda"
}

variable "glue_role_name" {
  type        = string
  description = "Name of the IAM role for Glue"
}

variable "input_bucket_arn" {
  type        = string
  description = "ARN of the input S3 bucket"
}

variable "output_bucket_arn" {
  type        = string
  description = "ARN of the output S3 bucket"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}