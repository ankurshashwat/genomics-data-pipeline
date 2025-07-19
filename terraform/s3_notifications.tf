resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = module.s3.input_bucket_arn
  depends_on    = [module.lambda, module.s3]
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = module.s3.input_bucket_id

  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".vcf"
  }

  depends_on = [aws_lambda_permission.allow_s3, module.lambda, module.s3]
}
