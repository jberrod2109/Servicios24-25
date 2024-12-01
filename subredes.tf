

#subredes ftp
resource "aws_subnet" "public_subnet_ftp" {
  vpc_id                  = aws_vpc.vpc_ftp.id
  cidr_block              = var.cidr_subred_pub_vpcftp
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name = var.nombre_subred_pubftp
  }
}

resource "aws_subnet" "private_subnet_ftp" {
  vpc_id            = aws_vpc.vpc_ftp.id
  cidr_block        = var.cidr_subred_priv_vpcftp
  availability_zone = element(data.aws_availability_zones.available.names, 0)

  tags = {
    Name = var.nombre_subred_privftp
  }
}

#subredes ldap

resource "aws_subnet" "public_subnet_ldap" {
  vpc_id                  = aws_vpc.vpc_ldap.id
  cidr_block              = var.cidr_subred_pub_vpcldap
  map_public_ip_on_launch = true
  availability_zone       = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name = var.nombre_subred_publdap
  }
}

resource "aws_subnet" "private_subnet_ldap" {
  vpc_id            = aws_vpc.vpc_ldap.id
  cidr_block        = var.cidr_subred_privldap
  availability_zone = element(data.aws_availability_zones.available.names, 1)

  tags = {
    Name = var.nombre_subred_privldap
  }
}
