#!/usr/bin/bash
# Este script instala y configura el servidor DHCP isc-dhcp-server
# Si no se ejecuta como root, se cierra.
# Añadido colores y validaciones

# DECLARACIÓN DE VARIABLES
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
RESET="\e[0m"

# -------------------------------------------------------------------------
# FUNCIONES

function f_menu(){
echo "${GREEN} ===== MENÚ CONFIGURACIÓN DHCP =======${RESET}"
echo "1. Borrar dependecias"
echo "2. Instalar DHCP server"
echo "3. Configurar DHCP"
echo "4. Salir"
echo "========================================"
read -p "${YELLOW}Elija una opción:${RESET} "
}

function f_salir(){
  echo -e "${RED}saliendo del script...${RESET}"
  sleep 3
  kill -15 $$
}

function f_borrar_dependencias(){
  echo -e "${CYAN}Solo responde 'si', si tienes paquetes rotos o tenías ya instalado 'isc-dhcp-server' y quieres empezar la instalación de 0. Si no es el caso, responde 'no':${RESET}"
  read -p "¿Quieres borrar las dependencias del paquete 'isc-dhcp-server'? (si/no): " respuesta
  if [[ $respuesta == 'si' ]]; then
    apt-get remove --purge isc-dhcp-server -y 
    apt-get autoremove -y
    clear
    echo "Dependencias borradas."
  else
    clear
    return 
  fi
}

function f_instalar_dhcpserver(){
  echo -e "${CYAN}¿Quieres instalar 'isc-dhcp-server'?${RESET}"
  read -p "(si/no): " respuesta2
  if [[ $respuesta2 == 'si' ]]; then
    echo -e "${CYAN}$(toilet -f emboss2 -F border 'INSTALANDO DHCP')${RESET}"
    apt-get install isc-dhcp-server -y > /dev/null
    echo "El servidor ha sido instalado."
  else
    f_salir
  fi
}

function f_bin_instalado(){
  paquete="isc-dhcp-server"
  if [[ $(dpkg -l | grep $paquete) ]]; then
    echo "El paquete $paquete está instalado"
    return 0
  else
    echo "El paquete $paquete no está instalado"
    return 1
  fi 
}

function f_soyroot(){
  echo "Comprobando que el script está siendo ejecutado por el usuario root..."
  sleep 1
  if [[ $UID -eq 0 ]]; then
    return 0
  else
    echo -e "${RED}Este script debe ejecutarse como root. Por favor, vuelve a entrar como superusuario.${RESET}"
    f_salir
  fi
}

function f_configurar_dhcp(){
  clear
  read -p "¿Desea configurar su servidor DHCP? (si/no): " respuesta3
  if [[ $respuesta3 == 'si' ]]; then
    echo "Introduce la interfaz de red (ej. eth0):"
    read INTERFAZ
    echo "Introduce el rango de inicio de IP (ej. 192.168.1.100):"
    read RANGO_INICIO
    echo "Introduce el rango de fin de IP (ej. 192.168.1.200):"
    read RANGO_FIN
    echo "Introduce la puerta de enlace (ej. 192.168.1.1):"
    read GATEWAY
    echo "Introduce la subred (ej. 192.168.1.0):"
    read SUBNET
    echo "Introduce la máscara de subred (ej. 255.255.255.0):"
    read NETMASK

    # Configurar interfaz en /etc/default/isc-dhcp-server
    sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$INTERFAZ\"/" /etc/default/isc-dhcp-server

    # Configurar /etc/dhcp/dhcpd.conf
    cat > /etc/dhcp/dhcpd.conf <<EOF
default-lease-time 600;
max-lease-time 7200;
authoritative;

subnet $SUBNET netmask $NETMASK {
  range $RANGO_INICIO $RANGO_FIN;
  option routers $GATEWAY;
  option subnet-mask $NETMASK;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOF
  ip addr add $GATEWAY/24 dev $INTERFAZ
  ip link set $INTERFAZ up

    # Activar reenvío IPv4
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

    # Reiniciar servicio
    echo -e "${GREEN}Reiniciando el servicio DHCP...${RESET}"
    systemctl restart isc-dhcp-server

    if systemctl is-active --quiet isc-dhcp-server; then
      echo -e "${GREEN}¡Servidor DHCP configurado y activo!${RESET}"
    else
      echo -e "${RED}Hubo un problema al iniciar el servicio DHCP.${RESET}"
    fi
  else
    echo "Configuración de DHCP cancelada."
    return
  fi
}

# -------------------------------------------------------------------------
# EJECUCIÓN PRINCIPAL

f_soyroot
apt update > /dev/null
apt upgrade -y > /dev/null
f_borrar_dependencias
f_instalar_dhcpserver
f_configurar_dhcp

