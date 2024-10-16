import os
import tftpy
import socket
import threading

class Tftp():
    def __init__(self, ip, port, directorio):
        self.ip = ip
        self.port = port
        self.directorio = directorio
        self.server = None
        self.running = True  

    def validar_ip(self):
        # Verifica si la IP es válida
        try:
            socket.inet_aton(self.ip)  
            return True
        except socket.error:
            return False

    def permisos_directorio(self):
        # Verifica si el directorio tiene permisos de lectura y escritura
        return os.access(self.directorio, os.R_OK | os.W_OK)

    def asignar_directorio(self):
        # Verificar si el directorio existe
        if not os.path.exists(self.directorio):
            print(f"El directorio {self.directorio} no existe. Creándolo...")
            os.makedirs(self.directorio)  # Crea el directorio si no existe

        if not self.permisos_directorio():
            print(f"El directorio {self.directorio} no tiene permisos de lectura y escritura.")
            return False

        self.server = tftpy.TftpServer(self.directorio)
        return True

    def escuchar(self):
        if self.running and self.server:
            print(f"Escuchando en {self.ip}:{self.port}...")
            self.server.listen(self.ip, self.port)

    def detener(self):
        print("Deteniendo el servidor...")
        # Detener el servidor TFTP
        self.running = False
        if self.server:
            self.server.stop()  

def main():
    ip = "0.0.0.0"  
    port = 69
    directorio = r"C:\copias"

    myFTP = Tftp(ip, port, directorio)

    if not myFTP.validar_ip():
        print(f"La IP {ip} no es válida.")
        return

    if not myFTP.asignar_directorio():
        return

    # Iniciar el servidor en un hilo separado
    server_thread = threading.Thread(target=myFTP.escuchar)
    server_thread.start()

    try:
        while True:
            command = input("Escriba 'stop' para detener el servidor: ")
            if command.lower() == 'stop':
                myFTP.detener()
                break
    except KeyboardInterrupt:
        myFTP.detener()

    server_thread.join()  # Espera a que el hilo del servidor termine
    print("Servidor detenido.")

if __name__ == "__main__":
    main()
