resource "aws_athena_database" "genomics_db" {
  name   = "genomics_db"
  bucket = var.output_bucket_name
}

resource "aws_athena_workgroup" "genomics_workgroup" {
  name = "genomics_workgroup"
  configuration {
    result_configuration {
      output_location = "s3://${var.output_bucket_name}/athena-queries/"
    }
  }
}