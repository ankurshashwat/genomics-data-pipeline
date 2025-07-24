output "glue_database_name" {
  value       = aws_glue_catalog_database.vcf_database.name
  description = "Name of the Glue catalog database"
}

output "glue_table_name" {
  value       = aws_glue_catalog_table.vcf_table.name
  description = "Name of the Glue catalog table"
}

output "glue_job_name" {
  value       = aws_glue_job.vcf_etl_job.name
  description = "Name of the Glue job"
}