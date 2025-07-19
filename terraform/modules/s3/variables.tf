variable "input_bucket_name" {
  type        = string
  description = "Name of the input S3 bucket (without suffix)"
}

variable "output_bucket_name" {
  type        = string
  description = "Name of the output S3 bucket (without suffix)"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "lambda_role_arn" {
  type        = string
  description = "ARN of the Lambda IAM role"
}

variable "glue_role_arn" {
  type        = string
  description = "ARN of the Glue IAM role"
}