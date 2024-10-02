from pysnmp.hlapi import getCmd, SnmpEngine, CommunityData, UdpTransportTarget, ContextData, ObjectType, ObjectIdentity

# Inicializar listas para IPs y comunidades
ips = []
comunidades = []

# Solicitar las IPs y las comunidades al usuario
while True:
    ip_input = input("Introduce una dirección IP (o escribe 'salir' para terminar): ")
    if ip_input.lower() == 'salir':
        break
    comunidad_input = input(f"Introduce la comunidad SNMP para la IP {ip_input} (o escribe 'salir' para terminar): ")
    if comunidad_input.lower() == 'salir':
        break
    
    ips.append(ip_input)
    comunidades.append(comunidad_input)

else:
    print("\nRealizando consultas SNMP...\n")
    # Usar un bucle for que itera sobre las listas de IPs y comunidades
    for i in range(len(ips)):
        # Crear el iterador para la solicitud SNMP con varios OIDs
        iterator = getCmd(
            SnmpEngine(),  # Crear un motor SNMP
            CommunityData(comunidades[i]),  # Nombre de la comunidad correspondiente
            UdpTransportTarget((ips[i], 161)),  # Dirección IP y puerto 161 (SNMP)
            ContextData(),  # Contexto vacío para SNMPv2c
            # Consultamos múltiples OIDs
            ObjectType(ObjectIdentity('1.3.6.1.2.1.1.1.0')),  # sysDescr (Descripción del sistema)
            ObjectType(ObjectIdentity('1.3.6.1.2.1.1.3.0')),  # sysUpTime (Tiempo de actividad)
            ObjectType(ObjectIdentity('1.3.6.1.2.1.2.1.0')),  # ifNumber (Número de interfaces)
            ObjectType(ObjectIdentity('1.3.6.1.4.1.9.2.1.58.0')),  # cpmCPUTotal5min (Uso de CPU en Cisco)
            ObjectType(ObjectIdentity('1.3.6.1.4.1.9.9.48.1.1.1.5.1'))  # ciscoMemoryPoolUsed (Uso de memoria en Cisco)
        )

        # Obtener la respuesta de la solicitud SNMP
        errorIndication, errorStatus, errorIndex, varBinds = next(iterator)

        # Manejo de errores y mostrar resultados
        if errorIndication:
            print(f"Error de conexión o solicitud para {ips[i]}: {errorIndication}")

        elif errorStatus:
            print(f"Error SNMP en {ips[i]}: {errorStatus.prettyPrint()} en {errorIndex and varBinds[int(errorIndex) - 1][0] or '?'}")

        else:
            print(f"Resultados para {ips[i]}:")
            for varBind in varBinds:
                print(' = '.join([x.prettyPrint() for x in varBind]))

        print("\n")  # Agregar una línea en blanco entre resultados de cada IP
