#!/bin/bash
## Este script sube dos archivos a /opt/exim autorep.noanswer y filtros, haciendo un backup de c/u y reinicia exim
ARCHIVOS=(filtros autorep.noanswer)

# Lista de servidores destino
SERVIDORES=(
labca300
)

# Ruta remota donde se copiarán los archivos
DESTINO_REMOTO="/opt/exim/"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  for ARCHIVO in "${ARCHIVOS[@]}"; do
    echo "Procesando archivo: $ARCHIVO"

    # Backup remoto si existe
    ssh "$SERVIDOR" "if [ -f ${DESTINO_REMOTO}${ARCHIVO} ]; then cp ${DESTINO_REMOTO}${ARCHIVO} ${DESTINO_REMOTO}${ARCHIVO}.bkp; echo 'Backup de $ARCHIVO hecho.'; else echo 'No existe $ARCHIVO, no se hace backup.'; fi"

    # Copiar archivo al servidor
    scp "./$ARCHIVO" "$SERVIDOR:$DESTINO_REMOTO" && echo "Archivo $ARCHIVO copiado con éxito a $SERVIDOR"
  done

  # Reiniciar Exim si está activo en el servidor remoto
#    ssh "$SERVIDOR" '
#    if systemctl is-active --quiet exim.service; then
#      systemctl restart exim.service && echo "[$(hostname)] Exim reiniciado correctamente."
#    else
#      echo "[$(hostname)] Exim está detenido. No se reinicia."
#    fi
#  '

  echo -e "\033[1;32m Completado para $SERVIDOR\033[0m"
  
done


