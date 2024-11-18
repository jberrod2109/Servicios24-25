#!/bin/bash
# Actualizar el repositorio e instalar Docker y s3fs
sudo apt-get update
sudo apt-get install -y docker.io
sudo apt-get install -y s3fs

# Iniciar servicio Docker
sudo systemctl start docker
sudo systemctl enable docker

# Crear Dockerfile para ProFTP
mkdir -p /home/admin/proftp
echo 'FROM debian:latest

# Instalar paquetes necesarios para ProFTP y LDAP
RUN apt-get update && apt-get install -y proftpd proftpd-mod-ldap ldap-utils
RUN apt-get install -y nano
# Configurar puertos pasivos de ProFTP
RUN echo "PassivePorts 1300 1301" >> /etc/proftpd/proftpd.conf

# Crear el usuario de FTP
RUN adduser --disabled-password --gecos "" jose
RUN echo "jose:jose" | chpasswd

# Copiar el archivo de configuración de ProFTP
COPY proftpd.conf /etc/proftpd/proftpd.conf

# Establecer el comando para ejecutar ProFTP
CMD ["proftpd", "--nodaemon"]

# Exponer puertos FTP
EXPOSE 20 21 1300 1301' > /home/admin/proftp/Dockerfile

# Crear archivo de configuración de ProFTP con LDAP
cat <<EOF > /home/admin/proftp/proftpd.conf
<IfModule mod_ldap.c>
  LDAPServer "ldap://$LDAP_SERVER_IP"
  LDAPBaseDN "dc=example,dc=com"
  LDAPBindDN "cn=admin,dc=example,dc=com"
  LDAPPassword "password"
  LDAPUserFilter "(&(objectClass=inetOrgPerson)(uid=%u))"
  LDAPGroupFilter "(&(objectClass=posixGroup)(memberUid=%u))"
  LDAPUserNameAttribute "uid"
  LDAPGroupNameAttribute "cn"
  LDAPLogLevel 0
</IfModule>

PassivePorts 1300 1301
EOF

# Crear archivo de credenciales de AWS
cd /home/admin
sudo mkdir .aws
sudo echo "[default]
aws_access_key_id=ASIARZPX7J2UOA3E4E7O
aws_secret_access_key=2wj1rn5gwmThHqf7MPW9i6AMEh3EDg3lpAHToBos
aws_session_token=IQoJb3JpZ2luX2VjEMn//////////wEaCXVzLXdlc3QtMiJGMEQCIBBHBPJlFRbWhlGb2j5tINOoFg9+m8YGcic4OjSsbopcAiA91J3kuA9ioSLihqAHYjCE7dAePXkdgsnoDDmwGy6vKCqxAghiEAAaDDEyMzQ2MzQ4NzE0NCIMmt7xex8SJHKTvURrKo4C99pVgszsAzXYq302dFuKnEJMeU3WfRV2VSxpxxvNWdR0wlypSdO6gZTGWezoYHMWa/ZPX7M+zp+Z8fNeolJmWFpgmcynQX2XHrNMf7zzXK3zqvzSAaNFwXObq4CM6AqFsoR/H60j2VaURXillUgQ9y6fCpbcckjYofIHeUTXvjSZrDezlbnR+X7cMFmEQZUg/PZi2wH/g5BaUjyh0gQ9KlU/8Mi55p+WBXGfzmEC9sttMZ4fS6JsKdjqlpBHUyJ/918lnXh8TW+Vf5faqCpr53RVEvd6Dwz7J9REM/KJGF6+qu5mUlWSbZYaeaKP8evePZS2X1mKxLvOWo3btPxP9UAE0QkWk/dFdvbbiSN2MOjd7bkGOp4BxIgNUsf8Q7xJSif/ogRLEC8kYhvPa2aAfJ6MhndsQD3Hg5/zBk6tCXvjsNgsZWp8bPWnAtpMOy3uScsp7/8vRAvjRFegNk2RA0skNEtLmCqcdMF6PfYHimf/dFGhF10DIB3WYLHBzh/sqJwdvwgW7LP8RUzD8unnFL7NqpR7RNfvBAbXMmP31lwmbAQoIVhQ8fu0Wo2B8WhEpgCx/EY=" > .aws/credentials
sudo mkdir -p /home/admin/carpeta_bucket
sudo mkdir -p /home/admin/ftp_bucket
sudo chmod 755 /home/admin/ftp_bucket
sudo mkdir -p /root/.aws
sudo cp /home/admin/.aws/credentials /root/.aws/credentials

# Montar el bucket S3
sudo s3fs proftpd-router /home/admin/ftp_bucket -o allow_other

# Construir y ejecutar el contenedor Docker con LDAP y configuración de ProFTP
cd /home/admin/proftp
sudo docker build -t proftp .
sudo docker run -d --name proftp -p 21:21 -p 20:20 -p 1300:1300 -p 1301:1301 -v /home/admin/ftp_bucket:/home/jose proftp
