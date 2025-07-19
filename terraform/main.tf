terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "iam" {
  source                = "./modules/iam"
  aws_account_id        = var.aws_account_id
  lambda_role_name      = var.lambda_role_name
  glue_role_name        = var.glue_role_name
  input_bucket_arn      = module.s3.input_bucket_arn
  output_bucket_arn     = module.s3.output_bucket_arn
}

module "s3" {
  source              = "./modules/s3"
  input_bucket_name   = var.input_bucket_name
  output_bucket_name  = var.output_bucket_name
  aws_account_id      = var.aws_account_id
  lambda_role_arn     = module.iam.lambda_role_arn
  glue_role_arn       = module.iam.glue_role_arn
}

module "lambda" {
  source                 = "./modules/lambda"
  lambda_function_name   = var.lambda_function_name
  lambda_role_arn        = module.iam.lambda_role_arn
  input_bucket_name      = module.s3.input_bucket_name
  output_bucket_name     = module.s3.output_bucket_name
  glue_job_name          = var.glue_job_name
  depends_on             = [module.s3, module.iam]
}

module "glue" {
  source                 = "./modules/glue"
  glue_role_arn          = module.iam.glue_role_arn
  input_bucket_name      = module.s3.input_bucket_name
  input_bucket_arn       = module.s3.input_bucket_arn
  input_bucket_id        = module.s3.input_bucket_id
  output_bucket_name     = module.s3.output_bucket_name
  glue_job_name          = var.glue_job_name
  depends_on             = [module.s3]
}

module "athena" {
  source                = "./modules/athena"
  aws_account_id        = var.aws_account_id
  output_bucket_name    = module.s3.output_bucket_name
}