#!/bin/bash

# Iniciar el servicio NordVPN
echo "Starting NordVPN service..."
/etc/init.d/nordvpn start
sleep 5

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
  if [ $? -eq 0 ]; then
    echo "LAN Discovery enabled successfully."
  else
    echo "Failed to enable LAN Discovery. Proceeding without it."
  fi
else
  echo "Disabling LAN Discovery..."
  nordvpn set lan-discovery disable
fi

# Agregar subred a la lista blanca si LAN Discovery está deshabilitado
if [ "$NORDVPN_LAN_DISCOVERY" != "enable" ] && [ -n "$NORDVPN_WHITELIST_SUBNET" ]; then
  echo "Adding subnet $NORDVPN_WHITELIST_SUBNET to whitelist..."
  nordvpn whitelist add subnet "$NORDVPN_WHITELIST_SUBNET"
  if [ $? -eq 0 ]; then
    echo "Subnet $NORDVPN_WHITELIST_SUBNET added to whitelist successfully."
  else
    echo "Failed to add subnet to whitelist."
  fi
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
