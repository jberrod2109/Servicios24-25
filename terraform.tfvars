aws_region           = "us-east-1"

cidr_blocks = [
  "192.168.244.0/24",    # CIDR para la VPC pública
  "192.168.244.0/25",    # CIDR para la subred pública
  "192.168.244.128/25",  # CIDR para la subred privada en la VPC pública
  "192.168.152.0/24",    # CIDR para la VPC privada
  "192.168.152.128/25"   # CIDR para la subred privada en la VPC privada
]

vpc_names            = ["vpc-publica", "vpc-privada"]
subnet_names         = ["public-subnet-vpc-public", "private-subnet-vpc-publica", "private-subnet-vpc-private"]
route_table_names    = ["vpc-public-route-table", "vpc-public-private-route-table", "vpc-private-route-table"]
internet_gateway_name = "vpc-public-gw"

# Valores para las variables ahora en terraform.tfvars
instance_type        = "t2.micro"
ami                  = "ami-064519b8c76274859"  # Cambia esto por el ID de la AMI que desees usar
key_name             = "ftp"                     # Asegúrate de que el par de claves ya exista en la región

     