output "ftp_instance_public_ip" {
  value = aws_instance.instancia_ftp.public_ip
  description = "IP pública de la instancia FTP"
}

output "ftp_instance_private_ip" {
  value = aws_instance.instancia_ftp.private_ip
  description = "IP privada de la instancia FTP"
}
