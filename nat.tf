# Elastic IP para NAT Gateway
# Asignar Elastic IP (EIP) para el NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"  
  tags = {
    Name = "NAT_EIP"
  }
}

# NAT Gateway en la subred pública de VPC LDAP
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id   # Asignamos el Elastic IP previamente creado
  subnet_id     = aws_subnet.public_subnet_ldap.id  # Subred pública de la VPC LDAP
  tags = {
    Name = "NAT_Gateway_LDAP"
  }
}


resource "aws_route" "private_to_nat" {
  route_table_id         = aws_route_table.private_route_table_ldap.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

# Internet Gateway para VPC FTP
resource "aws_internet_gateway" "igw_ftp" {
  vpc_id = aws_vpc.vpc_ftp.id

  tags = {
    Name = "InternetGateway_FTP"
  }
}

# Internet Gateway para VPC LDAP
resource "aws_internet_gateway" "igw_ldap" {
  vpc_id = aws_vpc.vpc_ldap.id

  tags = {
    Name = "InternetGateway_LDAP"
  }
}

# Tablas de rutas para VPC FTP
resource "aws_route_table" "public_route_table_ftp" {
  vpc_id = aws_vpc.vpc_ftp.id

  tags = {
    Name = "PublicRouteTable_FTP"
  }
}

resource "aws_route" "route_to_internet_ftp" {
  route_table_id         = aws_route_table.public_route_table_ftp.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_ftp.id
}
