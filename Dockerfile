# Usar Ubuntu 24.04 como base
FROM ubuntu:24.04

# Instalar dependencias y configurar el repositorio de NordVPN
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget apt-transport-https ca-certificates iptables && \
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc https://repo.nordvpn.com/gpg/nordvpn_public.asc && \
    echo "deb https://repo.nordvpn.com/deb/nordvpn/debian stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configurar variables de entorno
ENV NORDVPN_TOKEN ""
ENV NORDVPN_COUNTRY ""
ENV NORDVPN_GROUP ""
ENV NORDVPN_LAN_DISCOVERY "enable"

# Copiar el script de entrada
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Configurar el punto de entrada
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
