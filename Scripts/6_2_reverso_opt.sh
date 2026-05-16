#!/bin/bash
## Este script restaura los archivos /opt/exim/filtros y /opt/exim/autorep.noanswer 
## desde sus backups (.bkp) en cada servidor
## No reinicia Exim

ARCHIVOS=(filtros autorep.noanswer)

# Lista de servidores destino
SERVIDORES=(
chaco
)

# Ruta remota donde están los archivos
DESTINO_REMOTO="/opt/exim/"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mRestaurando en servidor: $SERVIDOR\033[0m"

  for ARCHIVO in "${ARCHIVOS[@]}"; do
    echo "Procesando archivo: $ARCHIVO"

    # Restaurar backup si existe
    ssh "$SERVIDOR" "if [ -f ${DESTINO_REMOTO}${ARCHIVO}.bkp ]; then cp -f ${DESTINO_REMOTO}${ARCHIVO}.bkp ${DESTINO_REMOTO}${ARCHIVO}; echo 'Restaurado $ARCHIVO desde backup.'; else echo 'No existe ${ARCHIVO}.bkp en $SERVIDOR'; fi"

  done

  # Reiniciar Exim si está activo en el servidor remoto
#    ssh "$SERVIDOR" '
#    if systemctl is-active --quiet exim.service; then
#      systemctl restart exim.service && echo "[$(hostname)] Exim reiniciado correctamente."
#    else
#      echo "[$(hostname)] Exim está detenido. No se reinicia."
#    fi
#  '
#
#  echo -e "\033[1;32m Completado para $SERVIDOR\033[0m"

done

## vuelvo todos menos el c170
