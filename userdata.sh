#!/bin/bash

Actualizar el sistema
sudo apt-get update

Instalar las dependencias necesarias
sudo apt-get install -y ca-certificates curl

Agregar la clave GPG de Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

Agregar el repositorio de Docker a las fuentes de Apt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

Actualizar los índices de paquetes
sudo apt-get update

Instalar Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

Iniciar y habilitar el servicio de Docker
sudo systemctl start docker
sudo systemctl enable docker

Crear un directorio para Docker y un Dockerfile
mkdir -p /home/docker
cd /home/docker

Crear el Dockerfile
touch Dockerfile
echo "FROM debian:latest" >> Dockerfile
echo "RUN apt-get update && apt-get install -y proftpd" >> Dockerfile
echo "EXPOSE 20 21 49152 65534" >> Dockerfile
echo 'CMD ["proftpd", "--nodaemon"]' >> Dockerfile

Construir la imagen de Docker
sudo docker build -t myproftpd .

Ejecutar el contenedor de ProFTPD
sudo docker run -d -p 20:20 -p 21:21 -p 49152:49152 -p 65534:65534 myproftpd
#acceder al contenedor
sudo docker exec -it recursing_stonebraker bash
#crear un usuario 
useradd -m ftp && echo "ftp:jose" | chpasswd
# Configurar ProFTPD
echo "DefaultRoot ~" >> /etc/proftpd/proftpd.conf 
echo "PassivePorts 49152-65534" >> /etc/proftpd/proftpd.conf

