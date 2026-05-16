#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
# Este script de backup hace lo siguiente: Detecta si esta activa la ip flotante, si lo esta genera un .tar.gz en el origen, limpia en el destino backups mayores a 7 dias y luego lo envia con un scp

# Configuración
IP_FLOTANTE="xxxx.xxx"
DEV="wan0"
ORIGEN_DIR="/var/www/public_html"
DESTINO="root@xx.xxx.xxx"
DEST_DIR="/mnt/bkp011/v5/esapp-front01"
FECHA=$(date +%d_%m_%Y)
BACKUP_FILE="/tmp/public_html_backup_$FECHA.tar.gz"

# Detectar IP flotante
if ip a show dev $DEV | grep -q "$IP_FLOTANTE"; then
    echo "IP flotante detectada, iniciando backup..."

    # Crear tar.gz del directorio
    tar -czf $BACKUP_FILE -C /var/www public_html

    # Limpiar backups remotos de más de 7 días
    ssh $DESTINO "find $DEST_DIR -name 'public_html_backup_*.tar.gz' -type f -mtime +7 -exec rm -f {} \;"

    # Enviar por scp al destino
    scp $BACKUP_FILE $DESTINO:$DEST_DIR

    # Borrar backup local
    rm -f $BACKUP_FILE

    echo "Backup completado correctamente."
else
    echo "IP flotante no detectada, no se realiza backup."
fi

exit 0
