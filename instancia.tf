terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
  vpc_id       = aws_vpc.vpc[0].id
  peer_vpc_id  = aws_vpc.vpc[1].id
  auto_accept  = true

  tags = {
    Name = "vpc-peer-public-private"
  }
}

# Actualizar las tablas de rutas para permitir el tráfico entre las VPCs
resource "aws_route" "peer_route_public_to_private" {
  route_table_id             = aws_route_table.route_table[1].id
  destination_cidr_block     = var.cidr_blocks[3]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "peer_route_private_to_public" {
  route_table_id             = aws_route_table.route_table[2].id
  destination_cidr_block     = var.cidr_blocks[1]
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
}

# Crear un grupo de seguridad en la VPC pública 
resource "aws_security_group" "ftp_sg" {
  vpc_id = aws_vpc.vpc[0].id

  # Reglas de entrada y salida
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 20
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1300
    to_port     = 1400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ftp-sg"
  }
}
  
# Referencia el nuevo grupo de seguridad en la instancia
resource "aws_instance" "instancia_ftp" {
  ami                    = var.ami                 # Usar la variable para la AMI
  instance_type          = var.instance_type       # Usar la variable para el tipo de instancia
  subnet_id              = aws_subnet.subnet[0].id  # La subred pública en la VPC correcta
  vpc_security_group_ids = [aws_security_group.ftp_sg.id]

  key_name   = var.key_name                       # Usar la variable para el nombre de la clave
  user_data  = file("userdata.sh")               # Reemplaza con el nombre de tu script

  tags = {
    Name = "ftp-s3"
  }
}
# Crear un bucket de S3 para almacenar archivos del servidor FTP
resource "aws_s3_bucket" "proftpd_bucket" {
  bucket = var.s3_bucket_name  # Usar la variable para el nombre del bucket

  tags = {
    Name = var.s3_bucket_name
  }
}
