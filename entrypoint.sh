#!/bin/bash

# Función para verificar el estado del servicio NordVPN
check_nordvpn_daemon() {
  for i in {1..5}; do
    nordvpn status &>/dev/null
    if [ $? -eq 0 ]; then
      echo "NordVPN daemon is ready."
      return 0
    fi
    echo "Waiting for NordVPN daemon to be ready... ($i/5)"
    sleep 2
  done
  echo "Error: Cannot reach NordVPN daemon after multiple attempts."
  exit 1
}

# Iniciar el servicio NordVPN
echo "Starting NordVPN service..."
/etc/init.d/nordvpn start
sleep 5

# Verificar si el demonio de NordVPN está disponible
check_nordvpn_daemon

# Verificar si el token está configurado
if [ -z "$NORDVPN_TOKEN" ]; then
  echo "Error: NORDVPN_TOKEN is not set. Provide your NordVPN token as an environment variable."
  exit 1
fi

# Iniciar sesión en NordVPN con el token
echo "Logging into NordVPN..."
nordvpn login --token "$NORDVPN_TOKEN"

# Configurar NordVPN para usar NordLynx
echo "Setting NordVPN protocol to NordLynx..."
nordvpn set technology nordlynx || echo "Failed to set technology to NordLynx. Proceeding with current configuration."

# Habilitar LAN Discovery si está configurado
if [ "$NORDVPN_LAN_DISCOVERY" = "enable" ]; then
  echo "Enabling LAN Discovery..."
  nordvpn set lan-discovery enable
else
  echo "Disabling LAN Discovery..."
  nordvpn set lan-discovery disable
fi

# Aplicar configuraciones adicionales si se proporcionan
if [ -n "$NORDVPN_SETTINGS" ]; then
  echo "Applying NordVPN settings..."
  for setting in $NORDVPN_SETTINGS; do
    nordvpn set $setting || echo "Failed to apply setting: $setting"
  done
fi

# Conectar al grupo o país especificado
if [ -n "$NORDVPN_GROUP" ]; then
  echo "Connecting to NordVPN group: $NORDVPN_GROUP"
  nordvpn connect --group "$NORDVPN_GROUP" "$NORDVPN_COUNTRY"
elif [ -n "$NORDVPN_COUNTRY" ]; then
  echo "Connecting to NordVPN country: $NORDVPN_COUNTRY"
  nordvpn connect "$NORDVPN_COUNTRY"
else
  echo "Connecting to the nearest NordVPN server..."
  nordvpn connect
fi

# Mostrar el estado de la conexión
nordvpn status

# Mantener el contenedor en ejecución
exec "$@"
