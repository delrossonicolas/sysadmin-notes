#!/bin/bash

# Script de reversión de cambios: restaura archivos .bkp

ARCHIVOS=(limite.auth.exim)

# Lista de servidores destino
SERVIDORES=(
aaa
)

# Ruta remota donde se encuentran los archivos
DESTINO_REMOTO="/etc/exim/dnsbl/"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mRevirtiendo cambios en: $SERVIDOR\033[0m"

  for ARCHIVO in "${ARCHIVOS[@]}"; do
    ARCHIVO_BKP="${ARCHIVO}.bkp"
    
    # Verificar y restaurar backup
    ssh "$SERVIDOR" "
      if [ -f ${DESTINO_REMOTO}${ARCHIVO_BKP} ]; then
        cp ${DESTINO_REMOTO}${ARCHIVO_BKP} ${DESTINO_REMOTO}${ARCHIVO} && echo 'Restaurado ${ARCHIVO} desde backup.'
      else
        echo 'Backup ${ARCHIVO_BKP} no encontrado. No se pudo restaurar.'
      fi
    "
  done

  # Reiniciar Exim si está activo en el servidor remoto
  ssh "$SERVIDOR" '
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "Exim reiniciado correctamente."
    else
      echo "['$(hostname)'] Exim está detenido. No se reinicia."
    fi
  '

  echo -e "\033[1;32mReversión completada para $SERVIDOR\033[0m"
done
