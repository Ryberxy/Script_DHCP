#!/usr/bin/bash
# Este script instala y configura el servidor DHCP isc-dhcp-server
# Si no se ejecuta como root, se cierra.

#Cargar la librería que contiene las funciones para ejecutar el script
source ./libreria_dhcp.sh

# -------------------------------------------------------------------------
# EJECUCIÓN 

f_soyroot

#Menú
while true; do
f_menu

if [ $opcion == "1" ]; then
    f_borrar_dependencias

elif [ $opcion == "2" ]; then
    f_decoracion
    f_comprobacion  
    

elif [ $opcion == "3" ]; then
    f_configurar_dhcp

elif [ $opcion == "4" ]; then
    f_salir
    break
fi

done
