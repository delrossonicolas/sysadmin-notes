#! /bin/bash

# Dada una lista CSV. Este script Instala el cliente de MySQL automáticamente

CSV_FILE="Lista_Linux_Mysql.csv"

# Verificar si el archivo CSV existe
if [[ ! -f "$CSV_FILE" ]]; then
    echo "El archivo CSV $CSV_FILE no existe"
    exit 1
fi

# Declarar el array de servidores
declare -a servidores

# Leer el archivo CSV y cargarlo en el array servidores
while IFS=',' read -r servidor _; do
    servidores+=("$servidor")
done < "$CSV_FILE"

# Chequeo en cada servidor
for servidor in "${servidores[@]}"; do 
    echo "--------------------------------------"
    echo "Conectando al servidor: $servidor"
    
    # Ejecutar instalación de MySQL en el servidor remoto
    ssh "$servidor" "yum -y install mysql-community-client DEVEL"

    echo "Instalación completada en $servidor."

  done

