import os
import tftpy
import socket
import threading
import boto3

class Tftp:
    def __init__(self, ip, port, directory, bucket_name):
        self.ip = ip
        self.port = port
        self.directory = directory
        self.bucket_name = bucket_name
        self.server = None
        self.running = True
        self.s3_client = boto3.client('s3')  

    def validate_ip(self):
        try:
            socket.inet_aton(self.ip)
            return True
        except socket.error:
            return False

    def check_directory_permissions(self):
        return os.access(self.directory, os.R_OK | os.W_OK)

    def setup_directory(self):
        if not os.path.exists(self.directory):
            print(f"El directorio {self.directory} no existe. Creándolo...")
            os.makedirs(self.directory)

        if not self.check_directory_permissions():
            print(f"El directorio {self.directory} no tiene permisos de lectura y escritura.")
            return False

        self.server = tftpy.TftpServer(self.directory)
        return True

    def listen(self):
        if self.running and self.server:
            print(f"Escuchando en {self.ip}:{self.port}...")
            self.server.listen(self.ip, self.port)

    def stop(self):
        print("Deteniendo el servidor...")
        self.running = False
        if self.server:
            self.server.stop()

    def create_bucket_if_not_exists(self):
        # Obtener la lista de buckets
        response = self.s3_client.list_buckets()
        bucket_names = [bucket['Name'] for bucket in response['Buckets']]
        
        if self.bucket_name in bucket_names:
            print(f"El bucket '{self.bucket_name}' ya existe.")
        else:
            # Crear el bucket
            self.s3_client.create_bucket(Bucket=self.bucket_name)
            print(f"El bucket '{self.bucket_name}' ha sido creado.")

    def upload_to_s3(self, file_path):
        if not os.path.isfile(file_path):
            print(f"El archivo {file_path} no existe.")
            return

        try:
            filename = os.path.basename(file_path)
            self.s3_client.upload_file(file_path, self.bucket_name, filename)
            print(f"Archivo {filename} subido a S3 en el bucket {self.bucket_name}.")
        except Exception as e:
            print(f"Error al subir el archivo {file_path} a S3: {e}")

def main():
    ip = "0.0.0.0"
    port = 69
    directory = r"C:\copias_bucket"
    bucket_name = "conf-router-jose29"  # Reemplaza con el nombre de tu bucket S3

    tftp_server = Tftp(ip, port, directory, bucket_name)

    if not tftp_server.validate_ip():
        print(f"La IP {ip} no es válida.")
        return

    if not tftp_server.setup_directory():
        return

    # Crear el bucket si no existe
    tftp_server.create_bucket_if_not_exists()

    # Iniciar el servidor en un hilo separado
    server_thread = threading.Thread(target=tftp_server.listen)
    server_thread.start()

    try:
        while True:
            command = input("Escriba 'stop' para detener el servidor o 'upload' para subir archivos: ")
            if command.lower() == 'stop':
                tftp_server.stop()
                break
            elif command.lower() == 'upload':
                files = os.listdir(directory)
                for file in files:
                    file_path = os.path.join(directory, file)
                    tftp_server.upload_to_s3(file_path)
            else:
                print("Comando no reconocido. Escriba 'stop' para detener el servidor o 'upload' para subir archivos.")

    except KeyboardInterrupt:
        tftp_server.stop()

    server_thread.join()
    print("Servidor detenido.")

if __name__ == "__main__":
    main()
