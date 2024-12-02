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

# Configurar credenciales de AWS
sudo mkdir -p ~/.aws
sudo cat > ~/.aws/credentials <<EOF
[default]
aws_access_key_id=ASIARZPX7J2UIROP4SDM
aws_secret_access_key=5M6ID6/ztwaecagytYetU+xTcvhJFwgeIkrQEpPA
aws_session_token=IQoJb3JpZ2luX2VjEBMaCXVzLXdlc3QtMiJIMEYCIQCxjOhhnrq6jJ7+hctSR6y2leg71FWDi+U2ZUCMXc7G9QIhAJnLCe7FYU654EJD9Jjv82UDlusrquzQVu7wK+KK5SFUKroCCLz//////////wEQABoMMTIzNDYzNDg3MTQ0IgwCvCnAm8TXMvDGghkqjgIjhOf+9Mt+CrJSd3fVOrCHoAYFcY+DVPGp8ut3QDyKJmJbWfS7nXzoMPh0OhbO7neKOcFxBRjKVY41cy0tZqbOaviZbCraLLdkrgI5r/aD0DAvoq1DoShuMHorf5vehJ12RtfsfnUKRWXRdqloV9aC0VZfNjB4QbJaNvYazONpSFvdIy1ybqihzbHQ5wSxu5OGHLgHadv+R7h+aosKRT2H9PceQG4S2KAOmgn5SIbWLixylh4SZGTL7eSlRdTeTgat80yP0JmKSdhQY1eX+GwAcC8xPOAISbnf3u4dh+JFQRdCjy+i8Uz7xoRFUVgfyUfUqPyQG0sWAy2anmoGgSPcsz2+1dLU0spnycC/+oQwg6W2ugY6nAFQPG4VfMlt2uYDiNXIYc2A7y4+svvq0V4nfaT0bgWlGdpe2CL/sc8BXoeByycqnaGo+eQiqgvx+RGmt6Rck7jGUSDa3C2gnrzkxLNOQHGHn+KVB2UZMcB9uN7BkdR8m0iNX3Q/YYkAI2RAwF9KfF9FamR8RWJQ9Wio7a1mHS4WzJkMzlF3MGAgSdTnVkW35dHvq0vzvvxYT0L3CEk=
#intsalacion de cron y ejecutar al arrancar
sudo apt install cron -y
sudo systemctl enable cron

# Crear directorio para el FTP
sudo mkdir -p /home/admin/ftp-ldap
sudo mkdir /mnt/bucket-s3
sudo chmod 777 /mnt/bucket-s3

# Asegurarse de que cron está instalado y en ejecución
sudo apt update
sudo apt install cron -y
sudo apt install rsync -y

# Iniciar el servicio de cron si no está en ejecución
sudo systemctl start cron
sudo systemctl enable cron

# Añadir el cron job automáticamente si no existe
(crontab -l 2>/dev/null; echo "* * * * * rsync -av --remove-source-files /home/admin/ftp-ldap/ /mnt/bucket-s3/") | crontab -



# Montar el bucket S3 en el directorio del FTP
sudo s3fs copias_router_joseBertos  /mnt/bucket-s3 -o allow_other


# Crear directorio para el Dockerfile
mkdir -p /home/dockerfile
cd /home/dockerfile

# Crear el Dockerfile
cat > Dockerfile <<EOF
FROM debian:latest

# Instalar dependencias necesarias
RUN apt-get update && apt-get install -y proftpd openssl nano proftpd-mod-crypto proftpd-mod-ldap ldap-utils

# Instalar el módulo de criptografía de ProFTPD
RUN apt-get update && apt-get install -y proftpd-mod-crypto && apt-get install proftpd-mod-ldap -y
RUN useradd -m -s /bin/bash jose && echo 'jose:jose' | chpasswd
RUN mkdir -p /home/admin/ftp-ldap && chown -R jose:jose /home/admin && chmod -R 777 /home/admin && chmod -R 777 /home/

# Generar el certificado SSL/TLS para ProFTPD
RUN openssl req -x509 -newkey rsa:2048 -sha256 -keyout /etc/ssl/private/proftpd.key -out /etc/ssl/certs/proftpd.crt -nodes -days 365 \
    -subj "/C=ES/ST=España/L=Granada/O=jose/OU=jose/CN=ftp.jose.com"

# Eliminar el bloque de cuotas anterior de /etc/proftpd/proftpd.conf
RUN sed -i '/<IfModule mod_quotatab.c>/,/<\/IfModule>/d' /etc/proftpd/proftpd.conf

# Configuración de ProFTPD
RUN echo "DefaultRoot /home/admin/ftp-ldap" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/modules.conf" >> /etc/proftpd/proftpd.conf && \
    echo "LoadModule mod_ldap.c" >> /etc/proftpd/modules.conf && \
    echo "Include /etc/proftpd/ldap.conf" >> /etc/proftpd/proftpd.conf && \
    echo "Include /etc/proftpd/tls.conf" >> /etc/proftpd/proftpd.conf && \
    echo "PassivePorts 1300 1301" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_tls.c>" >> /etc/proftpd/tls.conf && \
    echo "  TLSEngine on" >> /etc/proftpd/tls.conf && \
    echo "  TLSLog /var/log/proftpd/tls.log" >> /etc/proftpd/tls.conf && \
    echo "  TLSProtocol SSLv23" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateFile /etc/ssl/certs/proftpd.crt" >> /etc/proftpd/tls.conf && \
    echo "  TLSRSACertificateKeyFile /etc/ssl/private/proftpd.key" >> /etc/proftpd/tls.conf && \
    echo "</IfModule>" >> /etc/proftpd/tls.conf && \
    echo "<Anonymous /home/admin/ftp-ldap>" >> /etc/proftpd/proftpd.conf && \
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
    echo " LoadModule mod_tls.c" >> /etc/proftpd/modules.conf

# Añadir configuración de cuotas a /etc/proftpd/proftpd.conf
RUN echo "<IfModule mod_quotatab.c>" >> /etc/proftpd/proftpd.conf && \
    echo "QuotaEngine on" >> /etc/proftpd/proftpd.conf && \
    echo "QuotaLog /var/log/proftpd/quota.log" >> /etc/proftpd/proftpd.conf && \
    echo "<IfModule mod_quotatab_file.c>" >> /etc/proftpd/proftpd.conf && \
    echo "     QuotaLimitTable file:/etc/proftpd/ftpquota.limittab" >> /etc/proftpd/proftpd.conf && \
    echo "     QuotaTallyTable file:/etc/proftpd/ftpquota.tallytab" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

RUN cd /etc/proftpd
# Comandos ftpquota para crear tablas y registros
RUN cd /etc/proftpd && ftpquota --create-table --type=limit --table-path=/etc/proftpd/ftpquota.limittab && \
    ftpquota --create-table --type=tally --table-path=/etc/proftpd/ftpquota.tallytab && \
    ftpquota --add-record --type=limit --name=jose --quota-type=user --bytes-upload=20 --bytes-download=400 --units=Mb --files-upload=15 --files-download=50 --table-path=/etc/proftpd/ftpquota.limittab && \
    ftpquota --add-record --type=tally --name=jose --quota-type=user

# Configuración de LDAP en /etc/proftpd/proftpd.conf
RUN echo "<IfModule mod_ldap.c>" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPLog /var/log/proftpd/ldap.log" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPAuthBinds on" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPServer ldap://192.168.152.196:389" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPBindDN \"cn=admin,dc=joseftp,dc=com\" \"admin-ldap\"" >> /etc/proftpd/proftpd.conf && \
    echo "    LDAPUsers \"dc=joseftp,dc=com\" \"(uid=%u)\"" >> /etc/proftpd/proftpd.conf && \
    echo "</IfModule>" >> /etc/proftpd/proftpd.conf

# Configuración de LDAP en /etc/proftpd/ldap.conf
RUN echo "<IfModule mod_ldap.c>" >> /etc/proftpd/ldap.conf && \
    echo "    # Dirección del servidor LDAP" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPServer 192.168.152.196" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPBindDN \"cn=admin,dc=joseftp,dc=com\" \"admin-ldap\"" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPUsers ou=users,dc=joseftp,dc=com (uid=%u)" >> /etc/proftpd/ldap.conf && \
    echo "    CreateHome on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPGenerateHomedir on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPForceGeneratedHomedir on 755" >> /etc/proftpd/ldap.conf && \
    echo "    LDAPGenerateHomedirPrefix /home" >> /etc/proftpd/ldap.conf && \
    echo "</IfModule>" >> /etc/proftpd/ldap.conf

RUN echo "<Directory /home/admin/ftp-ldap>" >> /etc/proftpd/proftpd.conf && \
    echo "<Limit WRITE>" >> /etc/proftpd/proftpd.conf && \
    echo "  DenyUser carmona" >> /etc/proftpd/proftpd.conf && \
    echo "</Limit>" >> /etc/proftpd/proftpd.conf && \
    echo "</Directory>" >> /etc/proftpd/proftpd.conf 
# Exponer los puertos de FTP
EXPOSE 20 21 1300 1301

CMD ["sh", "-c", "chmod -R 777 /home/admin/ftp-ldap && proftpd --nodaemon"]


EOF

# Construir la imagen de Docker
docker build -t myproftpd .

# Ejecutar el contenedor
docker run -d --name proftpd -p 20:20 -p 21:21 -p 1300:1300 -p 1301:1301 -v /home/admin/ftp-ldap:/home/admin/ftp-ldap myproftpd

