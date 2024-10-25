terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Crear la primera VPC pública con el rango de IPs 192.168.144.0/24
resource "aws_vpc" "public_vpc" {
  cidr_block       = "192.168.144.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-publica"
  }
}

# Crear la Internet Gateway para la primera VPC pública
resource "aws_internet_gateway" "public_gw" {
  vpc_id = aws_vpc.public_vpc.id

  tags = {
    Name = "vpc-public-gw"
  }
}

# Crear la subred pública en el rango 192.168.144.0/25
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = "192.168.144.0/25"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-vpc-public"
  }
}

# Crear la tabla de rutas para la subred pública
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_gw.id
  }

  tags = {
    Name = "vpc-public-route-table"
  }
}

# Asociar la tabla de rutas con la subred pública
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Crear la subred privada en el rango 192.168.144.128/25 para la primera VPC
resource "aws_subnet" "private_subnet_public_vpc" {
  vpc_id     = aws_vpc.public_vpc.id
  cidr_block = "192.168.144.128/25"

  tags = {
    Name = "private-subnet-vpc-publica"
  }
}

# Crear la tabla de rutas para la subred privada en la primera VPC
resource "aws_route_table" "private_route_table_public_vpc" {
  vpc_id = aws_vpc.public_vpc.id

  tags = {
    Name = "vpc-public-private-route-table"
  }
}

# Asociar la tabla de rutas con la subred privada de la primera VPC
resource "aws_route_table_association" "private_association_public_vpc" {
  subnet_id      = aws_subnet.private_subnet_public_vpc.id
  route_table_id = aws_route_table.private_route_table_public_vpc.id
}

# Crear la segunda VPC privada con el rango de IPs 192.168.152.0/24
resource "aws_vpc" "private_vpc" {
  cidr_block       = "192.168.152.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "vpc-privada"
  }
}

# Crear la subred privada en el rango 192.168.152.128/25 en la segunda VPC
resource "aws_subnet" "private_subnet_private_vpc" {
  vpc_id     = aws_vpc.private_vpc.id
  cidr_block = "192.168.152.128/25"

  tags = {
    Name = "private-subnet-vpc-private"
  }
}

# Crear la tabla de rutas para la subred privada en la segunda VPC
resource "aws_route_table" "private_route_table_private_vpc" {
  vpc_id = aws_vpc.private_vpc.id

  tags = {
    Name = "vpc-private-route-table"
  }
}

# Asociar la tabla de rutas con la subred privada de la segunda VPC
resource "aws_route_table_association" "private_association_private_vpc" {
  subnet_id      = aws_subnet.private_subnet_private_vpc.id
  route_table_id = aws_route_table.private_route_table_private_vpc.id
}
