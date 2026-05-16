#!/bin/bash
## Este script sube un archivos a /etc/exim/dnsbl y reinicia exim

ARCHIVOS=(rbl.conf.exim)

SERVIDORES=(
111.111.111.1
)

DESTINO_REMOTO="/etc/exim/dnsbl/"

# Opciones SSH para evitar prompts y cortar rápido
SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  # Prueba rápida de conexión antes de trabajar
  if ! ssh $SSH_OPTS "$SERVIDOR" "true"; then
    echo "❌ No se pudo conectar a $SERVIDOR — se salta."
    continue
  fi

  for ARCHIVO in "${ARCHIVOS[@]}"; do
    echo "Procesando archivo: $ARCHIVO"

    # Backup remoto con fecha (YYYYMMDD)
    ssh $SSH_OPTS "$SERVIDOR" \
      "if [ -f ${DESTINO_REMOTO}${ARCHIVO} ]; then cp ${DESTINO_REMOTO}${ARCHIVO} ${DESTINO_REMOTO}${ARCHIVO}.bkp-\$(date +%Y%m%d); echo 'Backup de $ARCHIVO hecho.'; else echo 'No existe $ARCHIVO, no se hace backup.'; fi" \
      || { echo "❌ Error en backup en $SERVIDOR — sigo con el próximo archivo."; continue; }

    # Copiar archivo
    scp -o BatchMode=yes -o ConnectTimeout=10 "./$ARCHIVO" "$SERVIDOR:$DESTINO_REMOTO" \
      && echo "Archivo $ARCHIVO copiado con éxito a $SERVIDOR" \
      || { echo "❌ Error copiando $ARCHIVO a $SERVIDOR — sigo."; continue; }

  done

  # Reiniciar Exim si está activo
    ssh $SSH_OPTS "$SERVIDOR" '
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "[$(hostname)] Exim reiniciado correctamente."
    else
      echo "[$(hostname)] Exim está detenido. No se reinicia."
    fi
  '

  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done
