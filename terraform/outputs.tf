output "db_address" {
  value       = aws_db_instance.mysql.address
  description = "Endpoint privado do MySQL (só alcançável de dentro da VPC)."
}

output "db_port" {
  value = aws_db_instance.mysql.port
}

output "db_name" {
  value = aws_db_instance.mysql.db_name
}

output "db_security_group_id" {
  value = aws_security_group.rds.id
}

output "ssm_parameters" {
  value       = sort([for p in aws_ssm_parameter.contract : p.name])
  description = "Parâmetros publicados como contrato para os outros repositórios."
}
