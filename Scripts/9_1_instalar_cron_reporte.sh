#!/bin/bash
# Este script instala el crontab en crontab -e --- hecho

SERVIDORES=(
aaaaaa
)

SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo "Procesando $SERVIDOR"

  if ! ssh $SSH_OPTS "$SERVIDOR" "true"; then
    echo "❌ No se pudo conectar a $SERVIDOR — se salta."
    continue
  fi

  ssh $SSH_OPTS "$SERVIDOR" '

    # Agregar cron sin tocar los existentes
    (
      crontab -l 2>/dev/null
      echo "0 6 * * 2 bash -c '\''sleep \$((RANDOM % 7200)) && /scripts/reporte_correos/UNIFICADO_principal.sh -o /var/log/reporte_correos -x /scripts/reporte_correos >> /var/log/reporte_correos.log 2>&1'\''"
    ) | crontab -
  ' && echo "✅ Cron agregado en $SERVIDOR" \
    || echo "❌ Error agregando cron en $SERVIDOR"

done
