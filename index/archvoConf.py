from netmiko import ConnectHandler

class Router():
    def __init__(self, device_type, ip, username, password):
        self.device_type = device_type
        self.ip = ip
        self.username = username
        self.password = password
        self.conexion = None  # Para almacenar la conexión

    def establecer_conexion(self):
        # Crear un diccionario de conexión para Netmiko
        router_config = {
            "device_type": self.device_type,
            "ip": self.ip,
            "username": self.username,
            "password": self.password
        }
        try:
            # Intentar establecer la conexión
            self.conexion = ConnectHandler(**router_config)
            print(f"Conexión establecida con {self.ip}.")
        except Exception as e:
            # Capturar errores si la conexión falla
            print(f"Error al conectar con {self.ip}: {e}")
            self.conexion = None

    def ejecutar_configuracion(self, archivo_config):
        if self.conexion:
            try:
                # Abrir el archivo de configuración y leer los comandos
                with open(archivo_config, 'r') as f:
                    comandos = f.readlines()

                # Ejecutar cada comando desde el archivo de configuración
                for comando in comandos:
                    comando = comando.strip()  # Quitar espacios en blanco o saltos de línea
                    if comando:  # Asegurarse de que el comando no esté vacío
                        salida = self.conexion.send_command(comando)
                        print(f"Salida del comando '{comando}' en {self.ip}:")
                        print(salida)

            except Exception as e:
                print(f"Error al ejecutar la configuración desde {archivo_config} en {self.ip}: {e}")
        else:
            print(f"No se puede ejecutar la configuración. No hay conexión con {self.ip}.")

    def cerrar_conexion(self):
        if self.conexion:
            self.conexion.disconnect()
            print(f"Conexión con {self.ip} cerrada.")
        else:
            print(f"No hay conexión activa para cerrar en {self.ip}.")

# Uso de la clase
if __name__ == "__main__":
    # Instancias de diferentes dispositivos
    cisco = Router("cisco_ios", "192.168.244.12", "admin", "cisco123")
    mikrotik = Router("mikrotik_routeros", "192.168.244.13", "admin", "1")
    debian = Router("linux", "192.168.244.14", "gns3", "gns3")
    olive = Router("juniper_junos", "192.168.244.15", "root", "jose21")

    # Establecer conexiones
    cisco.establecer_conexion()
    mikrotik.establecer_conexion()
    debian.establecer_conexion()
    olive.establecer_conexion()

    # Ejecutar configuraciones desde archivos
    cisco.ejecutar_configuracion(".\index\cisco_config.txt ")
    mikrotik.ejecutar_configuracion(".\index\mikrotik_config.txt")
    debian.ejecutar_configuracion(".\index\debian_config.txt")
    olive.ejecutar_configuracion(".\index\olive_config.txt")

    # Cerrar conexiones
    cisco.cerrar_conexion()
    mikrotik.cerrar_conexion()
    debian.cerrar_conexion()
    olive.cerrar_conexion()
