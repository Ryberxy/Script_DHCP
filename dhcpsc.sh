#!/usr/bin/bash
#funcion soy_root

apt install update && apt install upgrade -y
#borrar dependencias dhcp (meter echo para hacer esto de forma opcional)
echo "¿Quieres instalar el paquete que contiene las dependencias para instalar el servidor DHCP?(si/no)"
if [[ $respuesta == 'si' ]] then












#-----------------------------------------------------------------------------------------------------------------------------------------
#ZONAFUNCIONES
function borrar_dependencias
echo "Solo responde 'si', si tienes paquetes rotos o tenías ya instalado 'isc-dhcp-server' y quieres empezar la instalacón de 0, si no es el caso responde no a continuación"
read -p "¿Quieres borrar las dependencias del paquete 'isc-dhcp-server'? (si/no)" respuesta
if [[ $respuesta == 'si' ]] then
apt-get remove --purge isc-dhcp-server -y 
apt-get autoremove -y
clear
echo "Dependencias borradas."

function instalar_dhcpserver
echo "Si tienes instalado el paquete 'isc-dhcp-server' responde 'no', en caso contrario responde 'si' (si/no)"
read -p "¿Quieres instalar 'isc-dhcp-server'?" respuesta2
if [[ $respuesta2 == 'si' ]] then
echo "Instalando el servidor DHCP..."
apt-get install isc-dhcp-server
