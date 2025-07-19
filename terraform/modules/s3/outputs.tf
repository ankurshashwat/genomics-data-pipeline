output "input_bucket_name" {
  value       = aws_s3_bucket.input_bucket.bucket
  description = "Name of the input S3 bucket"
}

output "output_bucket_name" {
  value       = aws_s3_bucket.output_bucket.bucket
  description = "Name of the output S3 bucket"
}

output "input_bucket_arn" {
  value       = aws_s3_bucket.input_bucket.arn
  description = "ARN of the input S3 bucket"
}

output "output_bucket_arn" {
  value       = aws_s3_bucket.output_bucket.arn
  description = "ARN of the output S3 bucket"
}

output "input_bucket_id" {
  value       = aws_s3_bucket.input_bucket.id
  description = "ID of the input S3 bucket"
}

output "kms_key_arn" {
  value       = aws_kms_key.bucket_key.arn
  description = "ARN of the KMS key for bucket encryption"
}