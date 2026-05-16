#!/bin/bash

# Este script chequea una linea del configure, y hace una lista al final, no reinicia exim -- Probado para centos 6

SERVIDORES=(
...
)

ENCONTRADOS=()   # Servidores con la línea
ERRORES=()       # Servidores con errores
OUTPUT_FILE="servidores_con_linea.txt"

# Vaciar archivo previo si existe
> "$OUTPUT_FILE"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\e[1;34m===== $SERVIDOR =====\e[0m"

  RESULTADO=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -qt "$SERVIDOR" 'bash -s' <<'EOF'
    if [ -f /etc/exim/configure ]; then
        grep "return_path = " /etc/exim/configure || echo "No se encontró la línea"
    else
        echo "NO EXISTE /etc/exim/configure"
    fi
EOF
  )

  SSH_EXIT=$?

  if [ $SSH_EXIT -ne 0 ]; then
    echo -e "\e[1;31mError de conexión (o requiere password). Se salta este servidor.\e[0m"
    ERRORES+=("$SERVIDOR")
    echo -e "\e------------------x---------------\e[0m"
    echo
    continue
  fi

  echo "$RESULTADO"

  if echo "$RESULTADO" | grep -q "return_path = "; then
    ENCONTRADOS+=("$SERVIDOR")
    echo "$SERVIDOR" >> "$OUTPUT_FILE"
  fi

  echo -e "\e------------------x---------------\e[0m"
  echo
done

# ============================
#    RESUMEN FINAL DE ERRORES
# ============================

if [ "${#ERRORES[@]}" -gt 0 ]; then
  echo -e "\n\e[1;31mServidores con errores de conexión:\e[0m"
  for S in "${ERRORES[@]}"; do
    echo "- $S"
  done
else
  echo -e "\n\e[1;32mNo hubo errores de conexión.\e[0m"
fi

echo -e "\n\e[1;32mArchivo generado: $OUTPUT_FILE\e[0m"
