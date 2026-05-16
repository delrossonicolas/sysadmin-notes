#!/bin/bash
# Este script crea la carpeta de logs en los servidores --- hecho


SERVIDORES=(
xxx.xxx.xxx.x
)

SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo "Procesando $SERVIDOR"

  if ! ssh $SSH_OPTS "$SERVIDOR" "true"; then
    echo "❌ No se pudo conectar a $SERVIDOR — se salta."
    continue
  fi

  ssh $SSH_OPTS "$SERVIDOR" '
    mkdir -p /var/log/reporte_correos
  ' && echo "✅ Carpeta creada en $SERVIDOR" \
    || echo "❌ Error creando carpeta en $SERVIDOR"

done
