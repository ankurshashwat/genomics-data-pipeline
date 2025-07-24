variable "glue_role_arn" {
  type        = string
  description = "ARN of the Glue IAM role"
}

variable "input_bucket_name" {
  type        = string
  description = "Name of the input S3 bucket (without suffix)"
}

variable "input_bucket_arn" {
  type        = string
  description = "ARN of the input S3 bucket"
}

variable "input_bucket_id" {
  type        = string
  description = "ID of the input S3 bucket"
}

variable "output_bucket_name" {
  type        = string
  description = "Actual name of the output S3 bucket (with suffix)"
}
variable "glue_job_name" {
  type        = string
  description = "Name of the Glue job"
}