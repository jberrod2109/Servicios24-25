# Región de AWS
variable "aws_region" {
  description = "La región de AWS a utilizar."
  type        = string
  default     = "us-east-1"
}

# CIDR blocks para las VPCs y subredes
variable "cidr_blocks" {
  description = "Lista de CIDR blocks para las VPCs y subredes."
  type        = list(string)
  default     = [
    "192.168.144.0/24",    # CIDR para la VPC pública
    "192.168.144.0/25",    # CIDR para la subred pública
    "192.168.144.128/25",  # CIDR para la subred privada en la VPC pública
    "192.168.152.0/24",    # CIDR para la VPC privada
    "192.168.152.128/25"   # CIDR para la subred privada en la VPC privada
  ]
}

# Nombres de recursos
variable "vpc_names" {
  description = "Nombres de las VPCs."
  type        = list(string)
  default     = ["vpc-publica", "vpc-privada"]
}

variable "subnet_names" {
  description = "Nombres de las subredes."
  type        = list(string)
  default     = ["public-subnet-vpc-public", "private-subnet-vpc-publica", "private-subnet-vpc-private"]
}

variable "route_table_names" {
  description = "Nombres de las tablas de rutas."
  type        = list(string)
  default     = ["vpc-public-route-table", "vpc-public-private-route-table", "vpc-private-route-table"]
}

variable "internet_gateway_name" {
  description = "Nombre del Internet Gateway para la VPC pública."
  type        = string
  default     = "vpc-public-gw"
}
