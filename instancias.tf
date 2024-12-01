# Instancia FTP en VPC FTP
resource "aws_instance" "ftp_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_ftp.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ftp_sg.id]
  user_data              = file("userdata.sh")

  tags = {
    Name = "instancia-ftpS3"
  }
}

# Instancia Bastión en VPC LDAP
resource "aws_instance" "bastion_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet_ldap.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "intancia bastionado"
  }
}

# Instancia LDAP en VPC LDAP
resource "aws_instance" "ldap_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_ldap.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ldap_sg.id]
  user_data              = file("ldap.sh")
  private_ip             = "192.168.152.196"
  depends_on             = [aws_nat_gateway.nat_gateway]

  tags = {
    Name = "instancia-ldap"
  }
}