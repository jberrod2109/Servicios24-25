#!/bin/bash

# Actualizar el sistema
sudo apt-get update

# Instalar dependencias necesarias para Docker
sudo apt-get install -y ca-certificates curl

# Agregar la clave GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Agregar el repositorio de Docker
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Actualizar los índices de paquetes e instalar Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Instalar s3fs
sudo apt update
sudo apt install s3fs -y

# Agregar el usuario 'admin' al grupo 'docker'
sudo usermod -aG docker admin

# Instrucción para aplicar el cambio 
newgrp docker

# Configurar credenciales de AWS
mkdir -p ~/.aws
cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=${AWS_ACCESS_KEY_ID}
aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}
aws_session_token=${AWS_SESSION_TOKEN}
EOF

# Crear directorio para el FTP
sudo mkdir -p /home/admin/ftps-s3
sudo chmod 755 /home/admin/ftps-s3

# Montar el bucket S3 en el directorio del FTP
sudo s3fs proftpd-router /home/admin/ftps-s3 -o allow_other

# Crear directorio para el Dockerfile
mkdir -p /home/docker
cd /home/docker

# Crear el Dockerfile
cat > Dockerfile <<EOF
FROM debian:latest

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y proftpd openssl nano

# Instalar el módulo de criptografía de ProFTPD
RUN apt-get update && apt-get install -y proftpd-mod-crypto

# Generar el certificado SSL/TLS para ProFTPD
RUN openssl req -x509 -newkey rsa:2048 -sha256 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 365 \
    -subj "/C=ES/ST=España/L=Granada/O=jose/OU=jose/CN=ftp.jose.com"
#generar cuotas y borrar modulo creado por defecto
RUN sed -i '/<IfModule mod_quotatab.c>/,+2d' /etc/proftpd/proftpd.conf

RUN ftpquota --create-table --type=limit --table-path=/etc/proftpd/ftpquota.limittab && ftpquota --create-table --type=tally --table-path=/etc/proftpd/ftpquota.tallytab

RUN cd /etc/proftpd && ftpquota --add-record --type=limit --name=jose --quota-type=user --bytes-upload=200 --bytes-download=400 --units=Mb --files-upload=15 --files-download=50 --table-path=/etc/proftpd/ftpquota.limittab && ftpquota --add-record --type=tally --name=jose --quota-type=user

# Configuración de ProFTPD
RUN echo "DefaultRoot /home/admin/ftps-s3" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/tls.conf" >> /etc/proftpd/proftpd.conf && \
    echo "LoadModule mod_ctrls_admin.c" >> /etc/proftpd/modules.conf && \
    echo "PassivePorts 1300 1301" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_tls.c>" >> /etc/proftpd/tls.conf && \
    echo "  TLSEngine on" >> /etc/proftpd/tls.conf && \
    echo "  TLSLog /var/log/proftpd/tls.log" >> /etc/proftpd/tls.conf && \
    echo "  TLSProtocol SSLv23" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateFile /etc/ssl/certs/proftpd.crt" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateKeyFile /etc/ssl/private/proftpd.key" >> /etc/proftpd/tls.conf && \
    echo "</IfModule>" >> /etc/proftpd/tls.conf && \
    echo "<Anonymous /home/admin/ftps-s3>" >> /etc/proftpd/proftpd.conf && \
    echo "  User ftp" >> /etc/proftpd/proftpd.conf && \
    echo "  Group nogroup" >> /etc/proftpd/proftpd.conf && \
    echo "  UserAlias anonymous ftp" >> /etc/proftpd/proftpd.conf && \
    echo "  RequireValidShell off" >> /etc/proftpd/proftpd.conf && \
    echo "  MaxClients 10" >> /etc/proftpd/proftpd.conf && \
    echo "  <Directory *>" >> /etc/proftpd/proftpd.conf && \
    echo "    <Limit WRITE>" >> /etc/proftpd/proftpd.conf && \
    echo "      DenyAll" >> /etc/proftpd/proftpd.conf && \
    echo "    </Limit>" >> /etc/proftpd/proftpd.conf && \
    echo "  </Directory>" >> /etc/proftpd/proftpd.conf && \
    echo "</Anonymous>" >> /etc/proftpd/proftpd.conf && \
    echo " LoadModule mod_tls.c" >> /etc/proftpd/modules.conf && \
    echo "<IfModule mod_quotatab.c>" >> /etc/proftpd/proftpd.conf && \ 
    echo "  QuotaEngine on" >> /etc/proftpd/proftpd.conf && \
    echo "  QuotaLog /var/log/proftpd/quota.log" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_quotatab_file.c>" >> /etc/proftpd/proftpd.conf && \
    echo "  QuotaLimitTable file:/etc/proftpd/ftpquota.limittab" >> /etc/proftpd/proftpd.conf && \
    echo "  QuotaTallyTable file:/etc/proftpd/ftpquota.tallytab" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

EXPOSE 20 21 1300-1301

# Crear usuario jose
RUN useradd -m -s /bin/bash jose && echo 'jose:jose' | chpasswd

CMD ["proftpd", "--nodaemon"]
EOF

# Construir la imagen de Docker
docker build -t myproftpd .

# Ejecutar el contenedor
docker run -d --name proftpd -p 20:20 -p 21:21 -p 1300-1301:1300-1301 -v /home/admin/ftps-s3:/home/admin/ftps-s3 myproftpd
