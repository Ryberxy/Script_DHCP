#!/usr/bin/bash
#Modificar f_soyroot para que cuando el script lo ejecute alguien que no es root no te permita ejecutarlo, y te diga que entres como root.
#Meter colores a los echos(rojos)




#DECLARACIONVARIABLES
# Colores ANSI
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"
WHITE="\e[37m"
RESET="\e[0m"

#-----------------------------------------------------------------------------------------------------------------------------------------
#ZONAFUNCIONES
function f_salir(){
echo "saliendo del script..."
sleep 3
kill -15 $$
}

function f_borrar_dependencias(){
echo -e "${CYAN}Solo responde 'si', si tienes paquetes rotos o tenías ya instalado 'isc-dhcp-server' y quieres empezar la instalacón de 0, si no es el caso responde no a continuación${RESET}"
read -p "¿Quieres borrar las dependencias del paquete 'isc-dhcp-server'? (si/no): " respuesta
  if [[ $respuesta == 'si' ]] then
     apt-get remove --purge isc-dhcp-server -y 
     apt-get autoremove -y
#    apt-get clean
     clear
     echo "Dependencias borradas."
  else
     clear
     return 
  fi
}

function f_instalar_dhcpserver(){
echo -e "${CYAN}Si tienes instalado el paquete 'isc-dhcp-server' responde 'no', en caso contrario responde 'si' (si/no)${RESET}"
read -p "¿Quieres instalar 'isc-dhcp-server'? (si/no): " respuesta2
  if [[ $respuesta2 == 'si' ]] then
     echo -e "${CYAN}$(toilet -f emboss2 -F border 'INSTALANDO DHCP')${RESET}"
     apt-get install isc-dhcp-server -y > /dev/null
     echo "El servidor ha sido instalado."
  else
     f_salir
  fi
}

function f_soyroot(){
  echo "Comprobando que el script está siendo ejecutado por el usuario root..."
  sleep 3
  if [[ $UID -eq 0  ]] ;then
#    echo "Soy root"
    return 0
  else
    echo "Por favor, ejecuta el script como usuario root."
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

#Ejecución
f_soyroot
apt update > /dev/null
apt upgrade -y > /dev/null
f_borrar_dependencias
f_instalar_dhcpserver
#f_configurar_dhcp   #no terminada
