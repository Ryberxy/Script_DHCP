#!/usr/bin/bash
# DECLARACIÓN DE VARIABLES
#COLORES
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

#Establece un menú con las distintas opciones
function f_menu(){
echo -e "\n"
echo "===== MENÚ CONFIGURACIÓN DHCP ======="
echo "1. Borrar dependecias"
echo "2. Instalar DHCP server"
echo "3. Configurar DHCP"
echo "4. Salir"
echo "========================================"
read -p "Elija una opción: " opcion
echo -e "\n"
}

#Función que sale del script terminando el proceso
function f_salir(){
  echo -e "${RED}saliendo del script...${RESET}"
  sleep 3
  kill -15 $$
}

#Esta función sirve para desinstalar isc-dhcp-server en caso de que haya paquetes mal instalados o rotos
function f_borrar_dependencias(){
  echo -e "${CYAN}Solo responde 'si', si tienes paquetes rotos o tenías ya instalado 'isc-dhcp-server' y quieres empezar la instalación de 0. Si no es el caso, responde 'no'\n${RESET}"
  read -p "$(echo -e ${CYAN}'¿Quieres borrar las dependencias del paquete 'isc-dhcp-server'? (si/no): '${RESET})" respuesta
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

#Instalar el paquete del servidor en linux
function f_instalar_dhcpserver(){
  echo -e "${CYAN}¿Quieres instalar 'isc-dhcp-server'?${RESET}"
  read -p "(si/no): " respuesta2
  if [[ $respuesta2 == 'si' ]]; then
    echo -e "${CYAN}$(toilet -f emboss2 -F border 'INSTALANDO DHCP')${RESET}"
    apt-get install isc-dhcp-server -y > /dev/null
    echo -e "${GREEN}El servidor ha sido instalado correctamente.${RESET}"
  else
    return
  fi
}

#Sirve para la decoración implementada
function f_decoracion (){
  toilet="toilet"
    
  if dpkg -s "$toilet" &> /dev/null; then
    clear
  else
    apt install "$toilet" -y
    clear
  fi
}

#Comprueba si el paquete "isc-dhcp-server" está instalado o no, si no lo está lo instala.
function f_comprobacion(){
  paquete1="isc-dhcp-server"
  if [[ $(dpkg -l | grep $paquete1) ]]; then
    echo "${GREEN}El paquete $paquete1 está instalado${RESET}"
    return 0
  else
    echo "El paquete $paquete1 no está instalado"
    f_decoracion
    f_instalar_dhcpserver
    return 1
  fi 
}

#Comprueba si el usuario root está ejecutando el script
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

#Esta función hace un backup del archivo dhcpd.config en su mismo directorio
function f_backup(){
  fichero=$(find / -type f -name "dhcpd.conf")
  if [ -f "$fichero" ]; then
     cp "$fichero" "$fichero".old
     echo "Se ha hecho un backup del archivo $fichero"
  else
    echo "No se ha encontrado el fichero de configuración DHCP, ¿Has instalado el dhcp server?"
    return f_menu
  fi
}

#Esta función te permite configurar tu DHCP haciendo antes el backup
function f_configurar_dhcp(){
  f_backup
  clear
  read -p "¿Desea configurar su servidor DHCP? (si/no): " respuesta3
  if [[ $respuesta3 == 'si' ]]; then
    read -p "Introduce la interfaz de red (ej: ens4): " INTERFAZ
    read -p "Introduce el rango de inicio de IP (ej: 192.168.1.100): " RANGO_INICIO
    read -p "Introduce el rango de fin de IP (ej: 192.168.1.200): " RANGO_FIN
    read -p "Introduce la puerta de enlace (ej: 192.168.1.1): " GATEWAY
    read -p "Introduce la subred (ej: 192.168.1.0): " SUBNET
    read -p "Introduce la máscara de subred (ej: 255.255.255.0): " NETMASK
    read -p "Ingrese la dirección de broadcast (ej: 192.168.1.255): " BROADCAST
    read -p "Ingrese el tiempo(segundos) por defecto que van a durar las concesiones: " DEFAULT_TIME
    read -p "Ingrese el tiempo(segundos) máximo que van a durar las concesiones: " MAX_TIME

    # Configurar interfaz en /etc/default/isc-dhcp-server
    sed -i "s/^INTERFACESv4=.*/INTERFACESv4=\"$INTERFAZ\"/" /etc/default/isc-dhcp-server

    # Configurar /etc/dhcp/dhcpd.conf 
    echo "" >> /etc/dhcp/dhcpd.conf
    echo "subnet $SUBNET netmask $NETMASK {" >> /etc/dhcp/dhcpd.conf
    echo "  range $RANGO_INICIO $RANGO_FIN;" >> /etc/dhcp/dhcpd.conf
    echo "  option routers $GATEWAY;" >> /etc/dhcp/dhcpd.conf
    echo "  option broadcast-address $BROADCAST;" >> /etc/dhcp/dhcpd.conf
    echo "  default-lease-time $DEFAULT_TIME;" >> /etc/dhcp/dhcpd.conf
    echo "  max-lease-time $MAX_TIME;" >> /etc/dhcp/dhcpd.conf
    echo "}" >> /etc/dhcp/dhcpd.conf

    ip addr add $GATEWAY/24 dev $INTERFAZ
    ip link set $INTERFAZ up

    # Activar reenvío IPv4
    sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf

    # Reiniciar servicio
    echo -e "${GREEN}Reiniciando el servicio DHCP...${RESET}"
    systemctl restart isc-dhcp-server

    if systemctl is-active --quiet isc-dhcp-server; then
      echo -e "${GREEN}¡Servidor DHCP configurado y activo!${RESET}"
    else
      echo -e "${RED}Ha ocurrido un error al iniciar el servicio DHCP.${RESET}"
    fi
  else
    echo "Configuración de DHCP cancelada."
    return
  fi
}
