# Ruta de peering hacia VPC LDAP
resource "aws_route" "route_to_ldap" {
  route_table_id         = aws_route_table.public_route_table_ftp.id
  destination_cidr_block = var.vpc_ldap_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route_table" "private_route_table_ftp" {
  vpc_id = aws_vpc.vpc_ftp.id

  tags = {
    Name = "PrivateRouteTable_FTP"
  }
}

resource "aws_route_table_association" "public_route_table_association_ftp" {
  subnet_id      = aws_subnet.public_subnet_ftp.id
  route_table_id = aws_route_table.public_route_table_ftp.id
}

resource "aws_route_table_association" "private_route_table_association_ftp" {
  subnet_id      = aws_subnet.private_subnet_ftp.id
  route_table_id = aws_route_table.private_route_table_ftp.id
}

# Tablas de rutas para VPC LDAP
resource "aws_route_table" "public_route_table_ldap" {
  vpc_id = aws_vpc.vpc_ldap.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_ldap.id
  }

  tags = {
    Name = "PublicRouteTable_LDAP"
  }
}

resource "aws_route_table" "private_route_table_ldap" {
  vpc_id = aws_vpc.vpc_ldap.id

  tags = {
    Name = "PrivateRouteTable_LDAP"
  }
}

resource "aws_route_table_association" "public_route_table_association_ldap" {
  subnet_id      = aws_subnet.public_subnet_ldap.id
  route_table_id = aws_route_table.public_route_table_ldap.id
}

resource "aws_route_table_association" "private_route_table_association_ldap" {
  subnet_id      = aws_subnet.private_subnet_ldap.id
  route_table_id = aws_route_table.private_route_table_ldap.id
}

# Peering entre VPCs
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id      = aws_vpc.vpc_ftp.id
  peer_vpc_id = aws_vpc.vpc_ldap.id
  auto_accept = true

  tags = {
    Name = "Peering_FTP_to_LDAP"
  }
}

resource "aws_route" "route_to_ftp_private" {
  route_table_id         = aws_route_table.private_route_table_ldap.id
  destination_cidr_block = var.vpc_ftp_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}