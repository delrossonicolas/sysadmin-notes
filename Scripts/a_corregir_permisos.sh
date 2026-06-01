#!/bin/bash
# Este script edita permisos
# Ejecutar en el primario / hacerlo en la imagen

SERVIDORES=(
c137
)

SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo "Procesando $SERVIDOR"

  if ! ssh $SSH_OPTS "$SERVIDOR" "true"; then
    echo "❌ No se pudo conectar a $SERVIDOR — se salta."
    continue
  fi

  ssh $SSH_OPTS "$SERVIDOR" "
    cd /opt/panel/bin || exit 1
    chown -R panel:root reporte_correos
    chmod -R 750 reporte_correos
  "
done

