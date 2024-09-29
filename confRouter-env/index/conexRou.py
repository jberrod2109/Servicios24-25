from netmiko import ConnectHandler
from netmiko import NetMikoTimeoutException, NetMikoAuthenticationException

# Configuración del router
router = {
    'device_type': 'mikrotik_routeros',  # Tipo de dispositivo (Cisco IOS)
    'ip': '192.168.244.13',         # Dirección IP del router (cambia a la IP de tu router)
    'username': 'admin',         # Nombre de usuario
    'password': '1',   # Contraseña
}

try:
    # Conectar al router
    print("Conectándose al router...")
    connection = ConnectHandler(**router)
    
    # Entrar en modo enable (si es necesario)
    connection.enable()
    print("Modo enable activado.")

    # Ejecutar un comando en el router 
    orden = 'ip/address/print'
    print(f"Ejecutando comando: {orden}")
    comando = connection.send_command(orden)

    # Mostrar el resultado del comando
    print("\n--- Resultado del comando ---")
    print(comando)

    # Cerrar la conexión
    connection.disconnect()
    print("\nConexión cerrada.")

except NetMikoTimeoutException:
    print("Error: Tiempo de espera agotado.")
except NetMikoAuthenticationException:
    print("Error: Autenticación fallida.")
except Exception as e:
    print(f"Error inesperado: {str(e)}")
