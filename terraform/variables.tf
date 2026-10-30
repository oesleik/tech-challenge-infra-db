variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type        = string
  default     = "tech-challenge"
  description = "Prefixo dos nomes dos recursos. O dashboard do New Relic (infra-k8s) procura a instância por \"<prefixo>-mysql\"."
}

variable "ssm_prefix" {
  type        = string
  default     = "/tech-challenge"
  description = "Prefixo dos parâmetros SSM (contrato entre repositórios)."
}

variable "rds_instance_class" {
  description = "Classe da instância Amazon RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Armazenamento inicial do RDS em GiB."
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Nome do banco de dados da aplicação."
  type        = string
  default     = "app_db"
}

variable "rds_master_username" {
  description = "Usuário administrativo do RDS."
  type        = string
  default     = "dbadmin"
}

variable "rds_master_password" {
  description = "Senha administrativa do RDS (via TF_VAR_rds_master_password)."
  type        = string
  sensitive   = true
  default     = ""
}
