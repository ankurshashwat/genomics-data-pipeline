resource "aws_s3_object" "glue_script" {
  bucket      = var.input_bucket_name
  key         = "glue_scripts/etl_script.py"
  source      = "${path.module}/etl_script.py"
  depends_on  = [var.input_bucket_id]
}

resource "aws_glue_catalog_database" "vcf_database" {
  name = "genomics_vcf_database"
}

resource "aws_glue_crawler" "vcf_crawler" {
  database_name = aws_glue_catalog_database.vcf_database.name
  name          = "${var.input_bucket_name}-crawler"
  role          = var.glue_role_arn
  s3_target {
    path = "s3://${var.output_bucket_name}/processed/"
  }
}

resource "aws_glue_job" "vcf_etl_job" {
  name     = var.glue_job_name
  role_arn = var.glue_role_arn
  command {
    script_location = "s3://${var.input_bucket_name}/glue_scripts/etl_script.py"
    python_version  = "3"
  }
  default_arguments = {
    "--TempDir"             = "s3://${var.output_bucket_name}/temp/"
    "--job-bookmark-option" = "job-bookmark-enable"
  }
  max_retries       = 1
  worker_type       = "G.1X"
  number_of_workers = 2
}

resource "aws_glue_catalog_table" "vcf_table" {
  name          = "vcf_data"
  database_name = aws_glue_catalog_database.vcf_database.name
  table_type    = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL              = "TRUE"
    "skip.header.line.count" = "1"
  }
  storage_descriptor {
    location      = "s3://${var.output_bucket_name}/processed/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      name                  = "parquet"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }
    columns {
      name = "CHROM"
      type = "string"
    }
    columns {
      name = "POS"
      type = "int"
    }
    columns {
      name = "REF"
      type = "string"
    }
    columns {
      name = "ALT"
      type = "string"
    }
    columns {
      name = "QUAL"
      type = "float"
    }
    columns {
      name = "sample1"
      type = "string"
    }
    columns {
      name = "sample2"
      type = "string"
    }
  }
}