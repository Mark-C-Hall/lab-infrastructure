output "address" {
  value       = aws_db_instance.mysql.address
  description = "MySQL Database Address"
}

output "port" {
  value       = aws_db_instance.mysql.port
  description = "MySQL Database Port"
}
