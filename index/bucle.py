from pysnmp.hlapi import getCmd, SnmpEngine, CommunityData, UdpTransportTarget, ContextData, ObjectType, ObjectIdentity

# Definir una lista con algunas IPs
ip = ['192.168.244.12', '192.168.244.13','192.168.244.15']

# Usar un bucle for que itera dependiendo del número de elementos en la lista
for i in range(len(ip)):
        # Crear el iterador para la solicitud SNMP con varios OIDs
    iterator = getCmd(
        SnmpEngine(),  # Crear un motor SNMP
        CommunityData('public'),  # Nombre de la comunidad (en este caso 'public')
        UdpTransportTarget((ip[i], 161)),  # Dirección IP del router y puerto 161 (SNMP)
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
        print(f"Error de conexión o solicitud: {errorIndication}")

    elif errorStatus:
        print(f"Error SNMP: {errorStatus.prettyPrint()} en {errorIndex and varBinds[int(errorIndex) - 1][0] or '?'}")

    else:
        for varBind in varBinds:
            print(' = '.join([x.prettyPrint() for x in varBind]))

    print("\n")  # Agregar una línea en blanco entre resultados de cada IP
