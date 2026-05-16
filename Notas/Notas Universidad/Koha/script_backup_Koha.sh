#!/bin/bash
# Ruta del archivo de configuración MySQL
RUTA_CONFIG_MYSQL="/opt/myscripts/koha_config_mysql.conf"

# Leer configuración de MySQL desde el archivo externo
source "$RUTA_CONFIG_MYSQL"

# Ruta del directorio de configuración de Koha
DIR_CONFIG_KOHA="/etc/koha"

# Variables de configuración
FECHA=$(date +"%Y%m%d")
DIR_RESPALDO="/opt/respaldo"
DIR_KOHA="/var/lib/koha"
DIR_SPOOL="/var/spool/koha"
BASE_DE_DATOS="koha_usuariousuario"

# Crear directorio de respaldo
mkdir -p "$DIR_RESPALDO/$FECHA"

# Respaldar la base de datos
mysqldump -u "$USUARIO_MYSQL" --password="$CONTRASENA_MYSQL" "$BASE_DE_DATOS" > "$DIR_RESPALDO/$FECHA/$BASE_DE_DATOS.sql"

# Respaldar archivos y directorios de Koha
cp -r "$DIR_KOHA" "$DIR_RESPALDO/$FECHA/"

# Respaldar archivos de configuración de Koha
cp -r "$DIR_CONFIG_KOHA" "$DIR_RESPALDO/$FECHA/"

# Respaldar archivos de configuración de Koha
cp -r "$DIR_SPOOL" "$DIR_RESPALDO/$FECHA/"

# Comprimir el respaldo
tar -czf "$DIR_RESPALDO/$FECHA.tar.gz" -C "$DIR_RESPALDO" "$FECHA"

# Eliminar el directorio de respaldo sin comprimir
rm -rf "$DIR_RESPALDO/$FECHA"

# Eliminar respaldos antiguos (opcional, descomenta si deseas mantener solo los últimos X días)
find "$DIR_RESPALDO" -type f -name "*.tar.gz" -mtime +0 -exec rm {} \;
