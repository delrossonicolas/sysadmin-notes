#!/bin/bash
## Copia exclusion de exim.bkp a exim, haciendo backup del actual y reiniciando Exim

# Lista de servidores destino
SERVIDORES=(
xxx.xxx.xxx.x
)

# Rutas remotas
DESTINO_REMOTO="/etc/exim"
DESTINO_BKP="/etc/exim.bkp"
ARCHIVO_ERRORES="./errores_permisos.txt"

# Limpiar archivo de errores al inicio
> "$ARCHIVO_ERRORES"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" "
    if [ -f $DESTINO_BKP/geoip/exclusion ]; then
      # Backup del archivo actual si existe
      if [ -f $DESTINO_REMOTO/geoip/exclusion ]; then
        cp $DESTINO_REMOTO/geoip/exclusion $DESTINO_REMOTO/geoip/exclusion.bak_\$(date +%Y%m%d%H%M%S)
      fi

      # Reemplazar archivo
      cp $DESTINO_BKP/geoip/exclusion $DESTINO_REMOTO/geoip/exclusion

      # Reiniciar Exim si está activo
      if systemctl is-active --quiet exim.service; then
        echo \"Esperando 3 segundos antes de reiniciar Exim...\"
        sleep 3
        systemctl restart exim.service && echo \"[\$(hostname)] Exim reiniciado correctamente.\"
      else
        echo \"[\$(hostname)] Exim está detenido. No se reinicia.\"
      fi
    else
      echo \"NO_EXISTE_BKP\"  # marca para el script principal
    fi
  " >/tmp/ssh_output.$$ 2>&1

  if grep -q "NO_EXISTE_BKP" /tmp/ssh_output.$$; then
    echo "$SERVIDOR" >> "$ARCHIVO_ERRORES"
    echo -e "\033[1;31m[$SERVIDOR] No existe $DESTINO_BKP/geoip/exclusion, agregado a $ARCHIVO_ERRORES\033[0m"
  else
    echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
  fi

  rm -f /tmp/ssh_output.$$
done
