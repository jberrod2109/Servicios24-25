# Configurar el proveedor de AWS
provider "aws" {
  region = "us-west-1" 
}
resource "aws_instance" "instancia-ftp" {
  ami           = "ami-064519b8c76274859"  # Cambia por la AMI deseada
  instance_type = "t2.micro"
  # Asigna la instancia a la subred pública
   subnet_id = "subnet-0aea309e7715581cf"

  # Especifica el ID del grupo de seguridad existente
  vpc_security_group_ids = ["sg-02f949c9c252e723e"]  # Reemplaza con tu grupo de seguridad

#Especifica el nombre de la clave pública existente
  key_name = "ftp"  # Reemplaza con el nombre de tu clave pública

  # user_data para ejecutar el script de setup
  user_data = file("userdata.sh")

  tags = {
    Name = "proftp"
  }
}
