# Imagen base
FROM ubuntu:24.04

# Variables para URLs y configuraciones
ENV NORDVPN_REPO_URL=https://repo.nordvpn.com/deb/nordvpn/debian
ENV NORDVPN_GPG_URL=https://repo.nordvpn.com/gpg/nordvpn_public.asc

# Actualización e instalación de dependencias
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        apt-transport-https \
        ca-certificates && \
    # Añadir clave GPG y repositorio
    wget -qO /etc/apt/trusted.gpg.d/nordvpn_public.asc $NORDVPN_GPG_URL && \
    echo "deb $NORDVPN_REPO_URL stable main" > /etc/apt/sources.list.d/nordvpn.list && \
    # Instalar NordVPN
    apt-get update && \
    apt-get install -y --no-install-recommends nordvpn && \
    # Limpiar caché de apt
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Añadir un script de configuración
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# ENTRYPOINT y CMD para iniciar NordVPN y configurar opciones
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
