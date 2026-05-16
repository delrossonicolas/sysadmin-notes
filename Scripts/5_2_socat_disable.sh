#!/bin/bash
## Este script chequea si esta enable el servicio socat.service y lo deshabilita si esta 

SERVIDORES=(
socat
)

OUTPUT_FILE="socat_enabled.txt"
> "$OUTPUT_FILE"   # limpiar archivo antes de empezar


for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" "
    HOSTNAME=\$(hostname)
    if systemctl is-enabled socat.service &>/dev/null; then
      echo \"[\$HOSTNAME] socat.service está ENABLE → deshabilitando...\"
      systemctl disable socat.service && echo \"[\$HOSTNAME] socat.service deshabilitado correctamente.\"
    else
      echo \"[\$HOSTNAME] socat.service ya está DISABLE\"
    fi
  "

  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done
