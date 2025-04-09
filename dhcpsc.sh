#!/usr/bin/bash
# Este script instala y configura el servidor DHCP isc-dhcp-server
# Si no se ejecuta como root, se cierra.
# Añadido colores y validaciones



# -------------------------------------------------------------------------
# FUNCIONES

source libreria_dhcp

# -------------------------------------------------------------------------
# EJECUCIÓN PRINCIPAL

f_soyroot
#apt update > /dev/null
#apt upgrade -y > /dev/null

#Hacer un while para devolver el menú
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
