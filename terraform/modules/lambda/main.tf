data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "validate_vcf" {
  filename         = data.archive_file.lambda_function_zip.output_path
  function_name    = var.lambda_function_name
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_function_zip.output_base64sha256
  timeout          = 30
  memory_size      = 128
  environment {
    variables = {
      GLUE_JOB_NAME      = var.glue_job_name
      OUTPUT_BUCKET_NAME = var.output_bucket_name
      INPUT_BUCKET_NAME  = var.input_bucket_name
    }
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}