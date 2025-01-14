#!/bin/bash

# Iniciar NordVPN
/etc/init.d/nordvpn start
sleep 5

# Pasar el token de autenticación
if [ -n "$NORDVPN_TOKEN" ]; then
    echo "Autenticando con NordVPN..."
    nordvpn login --token "$NORDVPN_TOKEN"
fi

# Configurar tecnología (por ejemplo, NordLynx)
if [ -n "$TECHNOLOGY" ]; then
    echo "Configurando la tecnología NordVPN a $TECHNOLOGY..."
    nordvpn set technology "$TECHNOLOGY"
fi

# Conectar al grupo P2P y país especificado
if [ -n "$NORDVPN_COUNTRY" ] && [ -n "$NORDVPN_GROUP" ] && [ "$NORDVPN_GROUP" = "p2p" ]; then
    echo "Conectando al grupo P2P en $NORDVPN_COUNTRY..."
    nordvpn connect --group p2p "$NORDVPN_COUNTRY"
fi

# Habilitar LAN Discovery si está configurado
if [ "$LAN_DISCOVERY" = "enable" ]; then
    echo "Habilitando LAN Discovery..."
    nordvpn set lan-discovery enabled
fi

# Añadir subredes a la lista de permitidos
if [ -n "$WHITELISTED_SUBNETS" ]; then
    echo "Añadiendo subredes a la lista de permitidos..."
    for subnet in $(echo "$WHITELISTED_SUBNETS" | tr ',' ' '); do
        echo "Añadiendo $subnet..."
        nordvpn whitelist add subnet "$subnet"
    done
fi

# Ejecutar el comando pasado como argumento (si existe)
exec "$@"
