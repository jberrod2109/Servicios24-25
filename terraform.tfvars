# Región de AWS
aws_region = "us-east-1"

# CIDR para las VPCs
vpc_ftp_cidr  = "192.168.244.0/24"
vpc_ldap_cidr = "192.168.152.0/24"

# CIDR para las  subredes
cidr_subred_pub_vpcftp  = "192.168.244.0/25"   
cidr_subred_priv_vpcftp = "192.168.244.128/25"    
cidr_subred_privldap    = "192.168.152.128/25"  
cidr_subred_pub_vpcldap = "192.168.152.0/25"       



# Nombres de las VPCs
nombre_vpcftp  = "VPC-ftp"
nombre_vpcldap = "VPC-privada"

# Nombres de las subredes
nombre_subred_pubftp  = "Subred-publica-vpc-ftp"
nombre_subred_privftp = "Subred-privada-vpc-ftp"
nombre_subred_privldap = "Subred-privada-vpc-ldap"
nombre_subred_publdap = "subred-publica-vpc-ldap"

# Configuración de la instancia EC2
instance_type = "t2.micro"
ami           = "ami-064519b8c76274859"  # Cambia a la AMI que desees usar
key_name      = "ftp"                    # Asegúrate de que el par de claves ya exista en la región

# Configuración del Bucket S3
bucket_name = "proftpd-router2129"
