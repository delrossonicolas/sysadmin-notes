#!/bin/bash
## Este script chequea si esta enable el servicio socat.service 

SERVIDORES=(
arreglo
arreglo2
)

OUTPUT_FILE="socat_enabled.txt"
> "$OUTPUT_FILE"   # limpiar archivo antes de empezar

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" "
    if systemctl is-enabled socat.service &>/dev/null; then
      echo \"[\$(hostname)] socat.service está ENABLE\"
      echo \$(hostname)
    else
      echo \"[\$(hostname)] socat.service está DISABLE\"
    fi
  " >> "$OUTPUT_FILE"

  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done

echo -e '\n\033[1;34mLista de servidores con socat.service habilitado guardada en: socat_enabled.txt\033[0m'
