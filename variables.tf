variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "vpc_ftp_cidr" {
  description = "CIDR block for VPC FTP"
  default     = ""
}

variable "vpc_ldap_cidr" {
  description = "CIDR block for VPC LDAP"
  default     = ""
}

variable "nombre_vpcftp" {
  description = "Name tag for VPC FTP"
  default     = ""
}

variable "nombre_vpcldap" {
  description = "Name tag for VPC LDAP"
  default     = ""
}

variable "cidr_subred_pub_vpcftp" {
  description = "CIDR block for Public Subnet FTP"
  default     = ""
}

variable "cidr_subred_priv_vpcftp" {
  description = "CIDR block for Private Subnet FTP"
  default     = ""
}

variable "nombre_subred_pubftp" {
  description = "Name tag for Public Subnet FTP"
  default     = ""
}

variable "nombre_subred_privftp" {
  description = "Name tag for Private Subnet FTP"
  default     = ""
}

variable "cidr_subred_pub_vpcldap" {
  description = "CIDR block for Public Subnet LDAP"
  default     = ""
}

variable "cidr_subred_privldap" {
  description = "CIDR block for Private Subnet LDAP"
  default     = ""
}

variable "nombre_subred_publdap" {
  description = "Name tag for Public Subnet LDAP"
  default     = ""
}

variable "nombre_subred_privldap" {
  description = "Name tag for Private Subnet LDAP"
  default     = ""
}

variable "ami" {
  description = "ami ID for instances"
  default     = ""
}

variable "instance_type" {
  description = "Instance type"
  default     = ""
}

variable "key_name" {
  description = "Key name for EC2 instances"
  default     = ""
}


variable "bucket_name" {
  description = "Nombre del bucket S3 que se contruye "
  default     = ""
}
