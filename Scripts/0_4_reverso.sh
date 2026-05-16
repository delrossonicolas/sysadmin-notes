#!/bin/bash
## Script reverso: restaura los backups (/etc/exim.bkp) en los servidores
## y reinicia el servicio Exim si está activo.

# Lista de servidores destino
SERVIDORES=(
.
)

# Ruta remota
DESTINO_REMOTO="/etc"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mRestaurando en servidor: $SERVIDOR\033[0m"

  ssh -o BatchMode=yes "root@$SERVIDOR" "
    if [ -d ${DESTINO_REMOTO}/exim.bkp ]; then
      if [ -d ${DESTINO_REMOTO}/exim ]; then
        rm -rf ${DESTINO_REMOTO}/exim
        echo 'Se eliminó carpeta exim actual'
      fi

      mv ${DESTINO_REMOTO}/exim.bkp ${DESTINO_REMOTO}/exim
      echo 'Se restauró exim desde backup'
    else
      echo 'No existe ${DESTINO_REMOTO}/exim.bkp en ${SERVIDOR}, no se pudo restaurar'
    fi
  "

  # Reiniciar Exim si está activo
  ssh -o BatchMode=yes "root@$SERVIDOR" '
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "[$(hostname)] Exim reiniciado tras restauración."
    else
      echo "[$(hostname)] Exim está detenido. No se reinicia."
    fi
  '

  echo -e "\033[1;32mRestauración completada en $SERVIDOR\033[0m"
done
