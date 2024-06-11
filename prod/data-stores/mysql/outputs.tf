output "address" {
  value       = module.aws_db_instance.address
  description = "MySQL Database Address"
}

output "port" {
  value       = module.aws_db_instance.port
  description = "MySQL Database Port"
}
