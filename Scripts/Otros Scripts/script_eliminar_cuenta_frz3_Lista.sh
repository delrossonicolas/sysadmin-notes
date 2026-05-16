#! /bin/bash 

# A este script se le pasa una lista de cuentas a borrar, y el mismo hace un ssh a panel3 por cada cuenta y ejecuta el removehosting - Funcional
# Listado de cuentas a eliminar en panel3
CSV_FILE="Lista_Linux_Full.csv"

listado_clientes=()

# Leer el archivo CSV  - While IFS procesa datos linea por linea - =+ agrega valor a un array o variable - Se probo eliminar el usuario centroco
while IFS=, read -r cliente; do
        listado_clientes+=("$cliente")
done < "$CSV_FILE"

echo "Los clientes leídos del archivo CSV son:"
for cliente in "${listado_clientes[@]}"; do
    echo "$cliente"
done


#Chequeo for 

for cliente in "${listado_clientes[@]}"; do

    echo "--------------------------------------"
    echo -e "\e[33m-Eliminando usuario: \e[37m$cliente "

	ssh "panel3@fzweb01.dominio.com"  "./fz3 removehosting -f $cliente && echo -e '$cliente'"   >> clientes_eliminados.log 2>&1|| echo -e "\e[31m   ---El cliente $cliente no existe--- \e[0m"
	
	echo "--------------------------------------"
done
