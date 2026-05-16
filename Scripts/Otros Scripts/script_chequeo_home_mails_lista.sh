#! /bin/bash

# Este script comprueba el contenido de /home y Mails dado un arreglo de servidor_usuarios por lista .csv

CSV_FILE="Lista_Linux.csv"

# Verificar si el archivo CSV existe
if [[ ! -f "$CSV_FILE" ]]; then
    echo "El archivo CSV $CSV_FILE no existe"
    exit 1
fi

# Declarar el array asociativo
declare -A servidor_usuarios

# Leer el archivo CSV y cargarlo en el array servidor_usuarios - While IFS procesa datos linea por linea
while IFS=',' read -r servidor usuario; do
        servidor_usuarios["$servidor"]="$usuario"
done < "$CSV_FILE"

# Mostrar contenido del array para verificar que se ha cargado correctamente (opcional)
echo -e "\e[33mContenido del array servidor_usuarios:\e[0m"
for servidor in "${!servidor_usuarios[@]}"; do
    echo -e "\e[90mServidor:\e[0m $servidor \e[90mUsuario:\e[0m ${servidor_usuarios[$servidor]}"
done

# Chequeo For

for servidor in "${!servidor_usuarios[@]}"; do 
    usuario="${servidor_usuarios[$servidor]}"		# Variable usuario (Accede al usuario tomando el servidor)  - ( esto imprime el usuario - echo ${servidor_usuarios["c156"]})

    echo "--------------------------------------"
    echo -e "\e[33mComprobando contenido para el usuario: \e[37m $usuario \e[0m \e[33m en el servidor: \e[0m  \e[37m $servidor \e[0m"

    # Comprobar contenido en /home
    echo -e "\e[36mContenido de Home home/$usuario: \e[0m"
    ssh "$servidor" "ls -l /home/$usuario && echo -e '\nEl usuario: $usuario tiene contenido en el servidor: $servidor'" >> Chequeo_home.log || echo -e "\e[31m   ---El directorio /home/$usuario no existe--- \e[0m" # ll no funciona, usar ls -l // || Doble pipe es OR, ejecutando el mensaje de error solo si el comando anterior falla --> Comillas separan comandos

    # Comprobar contenido en /Mails
    echo -e "\e[36mContenido de Mails Mails/$usuario: \e[0m"
    ssh "$servidor" "ls -l /Mails/$usuario && echo -e '\nEl usuario: $usuario tiene contenido en el servidor: $servidor'" >> Chequeo_mails.log || echo -e "\e[31m  ---El directorio /Mails/$usuario no existe--- \e[0m" # ll no funciona, usar ls -l

    echo "--------------------------------------"
done

