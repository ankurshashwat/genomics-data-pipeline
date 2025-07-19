output "athena_database_name" {
  value       = aws_athena_database.genomics_db.name
  description = "Name of the Athena database"
}

output "athena_workgroup_name" {
  value       = aws_athena_workgroup.genomics_workgroup.name
  description = "Name of the Athena workgroup"
}