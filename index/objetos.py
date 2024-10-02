from netmiko import ConnectHandler

class Router:
    def __init__(self, device_type, host, username, password):
        self.device_type = device_type
        self.host = host
        self.username = username
        self.password = password
        self.conexion = None  # Inicializamos la conexión como None

    def conectar(self):
        # Diccionario con la configuración del dispositivo
        conexion_params = {
            "device_type": self.device_type,
            "host": self.host,
            "username": self.username,
            "password": self.password
        }
        # Intentamos establecer la conexión
        try:
            self.conexion = ConnectHandler(**conexion_params)
            print(f"Conexión completada con {self.host}.")
        except Exception as e:
            print(f"Error al conectar con {self.host}: {e}")

    def comando(self, comando):
        # Verificamos si la conexión está establecida antes de enviar el comando
        if self.conexion:
            try:
                salida = self.conexion.send_command(comando)
                print(f"Salida del comando '{comando}' en {self.host}:\n{salida}")
            except Exception as e:
                print(f"Error al ejecutar el comando '{comando}' en {self.host}: {e}")
        else:
            print(f"No hay conexión establecida con {self.host}.")

    def desconectar(self):
        # Cerramos la conexión si está establecida
        if self.conexion:
            self.conexion.disconnect()
            print(f"Desconexión completada con {self.host}.")
        else:
            print(f"No hay conexión activa con {self.host} para desconectar.")

if __name__ == "__main__":
    # Instancias de diferentes dispositivos
    cisco = Router("cisco_ios", "192.168.244.12", "admin", "cisco123")
    mikrotik = Router("mikrotik_routeros", "192.168.244.13", "admin", "1")
    debian = Router("linux", "192.168.244.14", "gns3", "gns3")
    olive = Router("juniper_junos", "192.168.244.15", "root", "jose21")

    # Establecemos las conexiones y ejecutamos comandos
    cisco.conectar()
    cisco.comando("show running-config")
    
    mikrotik.conectar()  # Ahora conectamos antes de enviar un comando
    mikrotik.comando("ip/address/print")

    debian.conectar()
    olive.conectar()

    # Cerramos las conexiones
    cisco.desconectar()
    mikrotik.desconectar()
    debian.desconectar()
    olive.desconectar()
