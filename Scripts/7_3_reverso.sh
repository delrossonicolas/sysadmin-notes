# Este script hace un reverso del anterior
#!/bin/bash

# Lista de servidores destino
SERVIDORES=(
xxx.xxx.xxx.x
)

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;34mRevirtiendo en servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" '
    if [ -f /opt/exim/deny_senders26_06_25.bkp ]; then
      cp -f /opt/exim/deny_senders26_06_25.bkp /opt/exim/deny_senders
      echo "Backup restaurado en '"$SERVIDOR"'"
      
      if systemctl is-active --quiet exim.service; then
        systemctl restart exim.service && echo "Exim reiniciado correctamente en '"$SERVIDOR"'" || echo "Fallo al reiniciar Exim en '"$SERVIDOR"'"
      else
        echo "Exim estaba detenido en '"$SERVIDOR"', no se reinicia."
      fi
    else
      echo "No se encontró el backup en '"$SERVIDOR"', no se puede revertir."
    fi
  '
done
