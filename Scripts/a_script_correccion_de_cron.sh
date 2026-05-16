#!/bin/bash
# Reemplaza cron viejo (con RANDOM % 7200) por el nuevo

## corregir cron con el de la documentacion http://docs-iti.dat/display/ITLIN/Proyecto+reporte_correos

SERVIDORES=(
c137
)

SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

NEW='0 6 * * 2 /bin/bash /scripts/reporte_correos/UNIFICADO_principal.sh -o /var/log/reporte_correos -x /scripts/reporte_correos >> /var/log/reporte_correos.log 2>&1'

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo "Procesando $SERVIDOR"

  if ! ssh $SSH_OPTS "$SERVIDOR" "true"; then
    echo "❌ No se pudo conectar a $SERVIDOR — se salta."
    continue
  fi

  ssh $SSH_OPTS "$SERVIDOR" bash -s <<'EOF'
set -e

NEW='0 6 * * 2 /bin/bash /scripts/reporte_correos/UNIFICADO_principal.sh -o /var/log/reporte_correos -x /scripts/reporte_correos >> /var/log/reporte_correos.log 2>&1'

TMP=$(mktemp)

crontab -l > "$TMP"

# borrar la línea vieja (la que tiene el random 7200)
grep -vF "RANDOM % 7200" "$TMP" > "$TMP.new"
mv "$TMP.new" "$TMP"

# (opcional) borrar duplicados del NEW por si ya estaba
grep -vF "/scripts/reporte_correos/UNIFICADO_principal.sh" "$TMP" > "$TMP.new"
mv "$TMP.new" "$TMP"

# agregar la nueva
echo "$NEW" >> "$TMP"

crontab "$TMP"
rm -f "$TMP"

echo "✅ Cron actualizado"
EOF

  echo "✅ OK en $SERVIDOR"
  echo
done






