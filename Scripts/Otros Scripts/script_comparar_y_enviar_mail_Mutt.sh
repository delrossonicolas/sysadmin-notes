## Este script compara y envia a los destinatarios si hay diferencias entre los arhcivos ojs
#!/bin/bash

# Directorio donde se encuentran los certificados de Let's Encrypt
CERT_DIR="/var/www/sitio.ar/ssl"

# Archivo para almacenar los hashes de los certificados
HASH_FILE="/var/www/sitio.ar/private/hash.txt"

# Archivo temporal para almacenar los hashes actuales
TEMP_HASH_FILE="/var/www/sitio.ar/private/hash_actual.txt"

# Archivo de log para registrar los cambios
LOG_FILE="/var/www/sitio/private/certificate_changes.log"

CERT_ARCHIVE="/var/www/sitio/ssl/certificados.tar.gz"

# Dirección de correo del destinatario
EMAIL="mariano.delrosso@unr.edu.ar"

# Generar los hashes actuales de los certificados
find "$CERT_DIR" -type f \( -name "*.crt" -o -name "*.pem" -o -name "*.key" \) -exec sha256sum {} \; > "$TEMP_HASH_FILE"

# Recuperar las fechas del nuevo certificado
FECHASSL=$(openssl x509 -dates -noout < /var/www/sitio/ssl/sitio-ejemplo.crt)

# Comparar los hashes actuales con los anteriores
if ! diff "$HASH_FILE" "$TEMP_HASH_FILE" > /dev/null; then
    # Si hay cambios, registrar los cambios en el log y enviar un correo
    echo "Se detectaron cambios en los certificados SSL el $(date)" >> "$LOG_FILE"

    # Comprimir los certificados y claves privadas
    tar -czf "$CERT_ARCHIVE" -C "$CERT_DIR" .

    # Enviar correo con mutt
    echo "Se detectaron cambios en los certificados SSL del sitio sitio-ejemplo IP: x.x.xx.xx el $(date). Fechas del nuevo certificado: $FECHASSL" | mutt -s "Cambios en certificados SSL" "$EMAIL" -a "$CERT_ARCHIVE" -c "$EMAILCC1","$EMAILCC2","$EMAILCC3","$EMAILCC4"

    # Actualizar el archivo de hashes anteriores
    cp "$TEMP_HASH_FILE" "$HASH_FILE"
fi

# Limpiar el archivo temporal
rm "$TEMP_HASH_FILE"

# Borrar el archivo comprimido si existe
if [ -f "$CERT_ARCHIVE" ]; then
    rm "$CERT_ARCHIVE"
fi
