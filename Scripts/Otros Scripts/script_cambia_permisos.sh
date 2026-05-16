#!/bin/bash
## Script para Cambia permisos

# Lista de servidores destino
SERVIDORES=(
aaaaaaaa
)

# Ruta remota donde se copiarán los archivos
DESTINO_REMOTO="/etc"
ARCHIVO_ERRORES="./errores_permisos.txt"

# Limpiar archivo de errores al inicio (en tu PC, mismo directorio donde corrés el script)
> "$ARCHIVO_ERRORES"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  # Verificar si existe exim.bkp en el servidor remoto
  if ssh "$SERVIDOR" "[ -d $DESTINO_REMOTO/exim.bkp/dnsbl ]"; then
    # Copiar atributos desde exim.bkp a exim
    ssh "$SERVIDOR" "
      rsync -a --existing --ignore-times --no-perms --no-owner --no-group $DESTINO_REMOTO/exim.bkp/dnsbl/ $DESTINO_REMOTO/exim/dnsbl/
      rsync -a --existing --ignore-times --perms --owner --group $DESTINO_REMOTO/exim.bkp/dnsbl/ $DESTINO_REMOTO/exim/dnsbl/
      
      if systemctl is-active --quiet exim.service; then
        echo \"Esperando 3 segundos antes de reiniciar Exim...\"
        sleep 3
        systemctl restart exim.service && echo \"[\$(hostname)] Exim reiniciado correctamente.\"
      else
        echo \"[\$(hostname)] Exim está detenido. No se reinicia.\"
      fi
    "
  else
    echo "$SERVIDOR" >> "$ARCHIVO_ERRORES"
    echo -e "\033[1;31m[$SERVIDOR] No existe $DESTINO_REMOTO/exim.bkp/dnsbl, agregado a $ARCHIVO_ERRORES\033[0m"
  fi

  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done
