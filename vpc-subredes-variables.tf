terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Crear las VPCs usando count
resource "aws_vpc" "vpc" {
  count            = length(var.vpc_names) 
  cidr_block       = var.cidr_blocks[count.index * 3]
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_names[count.index]
  }
}

# Crear el Internet Gateway solo para la primera VPC (pública)
resource "aws_internet_gateway" "public_gw" {
  count  = 1
  vpc_id = aws_vpc.vpc[0].id

  tags = {
    Name = var.internet_gateway_name
  }
}

# Crear subredes usando count
resource "aws_subnet" "subnet" {
  count                   = 3
  vpc_id                  = aws_vpc.vpc[count.index == 2 ? 1 : 0].id
  cidr_block              = var.cidr_blocks[count.index + 1]
  map_public_ip_on_launch = count.index == 0 

  tags = {
    Name = var.subnet_names[count.index]
  }
}

# Crear tablas de rutas para cada subred
resource "aws_route_table" "route_table" {
  count  = 3
  vpc_id = aws_vpc.vpc[count.index == 2 ? 1 : 0].id

 #Bloque dinámico tabla de rutas pública
  dynamic "route" {
    for_each = count.index == 0 ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.public_gw[0].id
    }
  }

  tags = {
    Name = var.route_table_names[count.index]
  }
}

# Asociar cada tabla de rutas con la subred correspondiente
resource "aws_route_table_association" "association" {
  count          = 3
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.route_table[count.index].id
}
# Crear la conexión de peering entre las VPCs
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.vpc[0].id  # ID de la VPC pública
  peer_vpc_id = aws_vpc.vpc[1].id  # ID de la VPC privada
  auto_accept   = true
  tags = {
    Name = "vpc-peer-public-private"
  }
}

# Actualizar las tablas de rutas para permitir el tráfico entre las VPCs
resource "aws_route" "peer_route_public_to_private" {
  route_table_id            = aws_route_table.route_table[1].id # Tabla de rutas de la subred privada en VPC pública
  destination_cidr_block    = var.cidr_blocks[3]               # CIDR de la VPC privada
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id # ID de la conexión de peering
}

resource "aws_route" "peer_route_private_to_public" {
  route_table_id            = aws_route_table.route_table[2].id # Tabla de rutas de la subred privada en VPC privada
  destination_cidr_block    = var.cidr_blocks[1]               # CIDR de la VPC pública
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id # ID de la conexión de peering
}
