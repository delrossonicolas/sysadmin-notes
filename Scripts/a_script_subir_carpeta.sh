#!/bin/bash
## Este script sube la carpeta reporte_correos a /scripts en varios servidores con los cambios aplicados
## Editar permisos "chmod 775 UNIFICADO_*" despues de subir con el script 4
##ejecutar solo en el primario - cambiarlo en la imagen

SERVIDORES=(
c137
)

CARPETA_LOCAL="reporte_correos"
DESTINO_REMOTO="/scripts"

# Opciones SSH
SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  # Test rápido de conexión
  if ! ssh $SSH_OPTS "$SERVIDOR" "true"; then
    echo "❌ No se pudo conectar a $SERVIDOR — se salta."
    continue
  fi

  # Copiar carpeta (rsync crea reporte_correos automáticamente)
  rsync -avz --delete \
    -e "ssh $SSH_OPTS" \
    "$CARPETA_LOCAL" \
    "$SERVIDOR:$DESTINO_REMOTO/" \
    && echo "✅ Carpeta copiada correctamente en $SERVIDOR" \
    || echo "❌ Error copiando la carpeta en $SERVIDOR"

  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done



