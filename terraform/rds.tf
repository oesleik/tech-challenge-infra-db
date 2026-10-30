resource "aws_db_subnet_group" "this" {
  name        = "${var.name_prefix}-rds-subnets"
  description = "Sub-redes privadas do RDS do Tech Challenge"
  subnet_ids  = local.private_subnet_ids

  tags = {
    Name    = "${var.name_prefix}-rds-subnets"
    Project = "tech-challenge"
  }
}

# Sem regras inline: cada consumidor ganha uma regra separada. A do EKS fica aqui (o
# cluster já existe quando este repositório sobe); a da Lambda é criada pelo
# tech-challenge-lambda, que sobe depois. Regra geral: quem sobe depois cria o acesso.
resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds"
  description = "MySQL do Tech Challenge; acesso por regras separadas"
  vpc_id      = data.aws_ssm_parameter.vpc_id.insecure_value

  tags = {
    Name    = "${var.name_prefix}-rds"
    Project = "tech-challenge"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id            = aws_security_group.rds.id
  description                  = "MySQL a partir do EKS"
  referenced_security_group_id = data.aws_ssm_parameter.eks_cluster_security_group_id.insecure_value
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "rds_all" {
  security_group_id = aws_security_group.rds.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "mysql" {
  identifier     = "${var.name_prefix}-mysql"
  engine         = "mysql"
  instance_class = var.rds_instance_class

  db_name  = var.rds_db_name
  username = var.rds_master_username
  password = var.rds_master_password
  port     = 3306

  allocated_storage = var.rds_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  multi_az                   = false
  backup_retention_period    = 0
  auto_minor_version_upgrade = true
  deletion_protection        = false
  skip_final_snapshot        = true
  delete_automated_backups   = true
  apply_immediately          = true

  lifecycle {
    precondition {
      condition     = length(var.rds_master_password) >= 32
      error_message = "Defina DB_ROOT_PASSWORD com uma senha forte (32+ caracteres) antes de criar o RDS."
    }
  }

  tags = {
    Name    = "${var.name_prefix}-mysql"
    Project = "tech-challenge"
  }
}
