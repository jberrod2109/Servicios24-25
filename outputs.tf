
output "ftp_instance_public_ip" {
  description = "Dirección IP pública de la instancia FTP"
  value       = aws_instance.ftp_instance.public_ip
}

output "bastion_instance_public_ip" {
  description = "Dirección IP pública de la instancia Bastión"
  value       = aws_instance.bastion_instance.public_ip
}

output "ldap_instance_private_ip" {
  description = "Dirección IP privada de la instancia LDAP"
  value       = aws_instance.ldap_instance.private_ip
}

output "ftp_bucket_name" {
  description = "Nombre del Bucket S3 de FTP"
  value       = aws_s3_bucket.ftp_bucket.bucket
}

output "nat_eip" {
  description = "Elastic IP del NAT Gateway"
  value       = aws_eip.nat.public_ip
}
