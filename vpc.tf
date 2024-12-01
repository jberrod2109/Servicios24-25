# VPC FTP - Con subred pública y privada
resource "aws_vpc" "vpc_ftp" {
  cidr_block = var.vpc_ftp_cidr
  tags = {
    Name = var.nombre_vpcftp
  }
}


# VPC LDAP - Con subred pública y privada
resource "aws_vpc" "vpc_ldap" {
  cidr_block = var.vpc_ldap_cidr
  tags = {
    Name = var.nombre_vpcldap
  }
}