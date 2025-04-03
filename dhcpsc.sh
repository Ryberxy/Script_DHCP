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
function f_borrar_dependencias(){
echo "Solo responde 'si', si tienes paquetes rotos o tenías ya instalado 'isc-dhcp-server' y quieres empezar la instalacón de 0, si no es el caso responde no a continuación"
read -p "¿Quieres borrar las dependencias del paquete 'isc-dhcp-server'? (si/no): " respuesta
  if [[ $respuesta == 'si' ]] then
     apt-get remove --purge isc-dhcp-server -y 
     apt-get autoremove -y
     clear
     echo "Dependencias borradas."
  else
     return 
  fi
}

function f_instalar_dhcpserver(){
echo "Si tienes instalado el paquete 'isc-dhcp-server' responde 'no', en caso contrario responde 'si' (si/no)"
read -p "¿Quieres instalar 'isc-dhcp-server'? (si/no): " respuesta2
  if [[ $respuesta2 == 'si' ]] then
     echo "Instalando el servidor DHCP..."
     apt-get install isc-dhcp-server -y
     clear
  else
     return
  fi
}

function f_soyroot(){
  if [[ $UID -eq 0  ]] ;then
#    echo "Soy root"
    return 0
  else
#    echo "No soy root"
    return 1
  fi
}

function f_configurar_dhcp(){
read -p "¿Desea configurar su servidor DHCP? (si/no): " respuesta3
  if [[ $respuesta3 == 'si' ]] then
    #Falta Configuracion
  else
    return
  fi
}

#Ejecución
f_soyroot
apt update && apt upgrade -y
f_borrar_dependencias
f_instalar_dhcpserver
f_configurar_dhcp
