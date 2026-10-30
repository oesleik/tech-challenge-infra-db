# Entrada: parâmetros publicados pelo tech-challenge-infra-k8s. Se o infra-k8s não foi
# aplicado, o plan falha aqui (o workflow de deploy já checa antes, com mensagem melhor).

data "aws_ssm_parameter" "vpc_id" {
  name = "${var.ssm_prefix}/network/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "${var.ssm_prefix}/network/private_subnet_ids"
}

data "aws_ssm_parameter" "eks_cluster_security_group_id" {
  name = "${var.ssm_prefix}/eks/cluster_security_group_id"
}

# Saída: o que a app (tech-chalange) e a Lambda (tech-challenge-lambda) consomem.
# Renomear ou remover um parâmetro é uma mudança de contrato: ver README.md.
locals {
  private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.insecure_value)

  ssm_parameters = {
    "db/address"           = aws_db_instance.mysql.address
    "db/port"              = tostring(aws_db_instance.mysql.port)
    "db/name"              = aws_db_instance.mysql.db_name
    "db/security_group_id" = aws_security_group.rds.id
  }
}

resource "aws_ssm_parameter" "contract" {
  for_each = local.ssm_parameters

  name  = "${var.ssm_prefix}/${each.key}"
  type  = "String"
  value = each.value
}
