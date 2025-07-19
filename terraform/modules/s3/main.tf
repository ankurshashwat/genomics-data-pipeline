resource "random_string" "bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_kms_key" "bucket_key" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket" "input_bucket" {
  bucket = "${var.input_bucket_name}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "input_bucket_encryption" {
  bucket = aws_s3_bucket.input_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "${var.output_bucket_name}-${random_string.bucket_suffix.result}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "output_bucket_encryption" {
  bucket = aws_s3_bucket.output_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_policy" "input_bucket_policy" {
  bucket = aws_s3_bucket.input_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.lambda_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.input_bucket.arn,
          "${aws_s3_bucket.input_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = var.glue_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.input_bucket.arn,
          "${aws_s3_bucket.input_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "s3:PutBucketNotification"
        Resource = aws_s3_bucket.input_bucket.arn
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "output_bucket_policy" {
  bucket = aws_s3_bucket.output_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = var.glue_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:PutObjectAcl"
        ]
        Resource = [
          aws_s3_bucket.output_bucket.arn,
          "${aws_s3_bucket.output_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.output_bucket.arn,
          "${aws_s3_bucket.output_bucket.arn}/*"
        ]
      }
    ]
  })
}