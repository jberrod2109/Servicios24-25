from netmiko import ConnectHandler
from netmiko import NetMikoTimeoutException, NetMikoAuthenticationException

# Solicitar los datos al usuario
ip = input("Ingrese la IP del router: ").strip()
username = input("Ingrese el nombre de usuario: ").strip()
password = input("Ingrese la contraseña: ").strip()

# Crear el diccionario básico de conexión
router = {
    'device_type': 'autodetect',  # Para este caso, se usará este valor como marcador
    'ip': ip,
    'username': username,
    'password': password,
}

# Definir comandos para detectar el tipo de dispositivo
def detect_device_type(connection):
    # Enviar comandos que podrían funcionar en varios dispositivos
    try:
        # Comando para Cisco IOS
        output = connection.send_command("show version")
        if "Cisco IOS" in output or "Cisco" in output:
            return "cisco_ios"
    except:
        pass

    try:
        # Comando para MikroTik RouterOS
        output = connection.send_command("/system resource print")
        if "routerboard" in output or "version" in output:
            return "mikrotik_routeros"
    except:
        pass

    try:
        # Comando para Juniper Junos
        output = connection.send_command("show version")
        if "JUNOS" in output:
            return "juniper_junos"
    except:
        pass

    try:
        # Comando para dispositivos Debian/Linux
        output = connection.send_command("uname -a")
        if "Linux" in output:
            return "debian"
    except:
        pass

    return None

try:
    # Intentar conectarse al dispositivo
    print(f"Conectándose al dispositivo en {ip}...")
    # Vamos a probar usando 'device_type' como 'cisco_ios', para luego detectar el tipo real
    router['device_type'] = 'cisco_ios'  # Probamos con un valor genérico primero
    connection = ConnectHandler(**router)

    # Detectar el tipo de dispositivo
    detected_device_type = detect_device_type(connection)

    if detected_device_type:
        print(f"Dispositivo detectado como: {detected_device_type}")
        # Ahora que sabemos el tipo de dispositivo, podemos usarlo para más comandos
        router['device_type'] = detected_device_type
        connection.disconnect()

        # Reconectar con el tipo de dispositivo detectado
        connection = ConnectHandler(**router)

        # Definir múltiples comandos dependiendo del tipo de dispositivo detectado
        if detected_device_type == "cisco_ios":
            # Comandos para Cisco IOS
            comandos_config = [
                "interface GigabitEthernet0/1",
                "ip address 192.168.1.1 255.255.255.0",
                "no shutdown",
                "exit",
                "do wr "
            ]
            # Enviar los comandos de configuración
            print("\n--- Aplicando configuración en Cisco IOS ---")
            output = connection.send_config_set(comandos_config)
            print(output)

        elif detected_device_type == "mikrotik_routeros":
            # Comandos para MikroTik RouterOS
            comandos_mikrotik = [
                "/ip address add address=192.168.10.1/24 interface=ether1",
                "/interface print",
                "/system identity set name=MikroTikRouter"
            ]
            # Enviar los comandos de configuración
            print("\n--- Aplicando configuración en MikroTik RouterOS ---")
            output = connection.send_config_set(comandos_mikrotik)
            print(output)

        elif detected_device_type == "juniper_junos":
            # Comandos para Juniper Junos
            comandos_junos = [
                "set system host-name JuniperRouter",
                "set interfaces ge-0/0/1 unit 0 family inet address 192.168.20.1/24",
                "commit"
            ]
            # Enviar los comandos de configuración
            print("\n--- Aplicando configuración en Juniper Junos ---")
            output = connection.send_config_set(comandos_junos)
            print(output)

        elif detected_device_type == "linux":
            # Comandos para Debian/Linux
            comandos_debian = [
                "ifconfig eth0 up",
                "ifconfig eth0 192.168.30.1 netmask 255.255.255.0",
                "hostnamectl set-hostname DebianServer"
            ]
            # Enviar los comandos de configuración
            print("\n--- Aplicando configuración en Debian/Linux ---")
            output = connection.send_config_set(comandos_debian)
            print(output)
    
    else:
        print("No se pudo detectar el tipo de dispositivo.")

    # Cerrar la conexión
    connection.disconnect()
    print("\nConexión cerrada.")

except NetMikoTimeoutException:
    print("Error: Tiempo de espera agotado.")
except NetMikoAuthenticationException:
    print("Error: Autenticación fallida.")
except Exception as e:
    print(f"Error inesperado: {str(e)}")
