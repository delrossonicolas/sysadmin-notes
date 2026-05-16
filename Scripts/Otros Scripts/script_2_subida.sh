#!/bin/bash
# Script para copiar ./exim a /etc/exim en servidores remotos con batchmode por errores de ssh y reinicio de exim
# Ejecuta como root

SERVIDORES=(
xxx1
xxx2
)

DESTINO_REMOTO="/etc/exim"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  # Copiar todo el contenido de ./exim al destino remoto como root (no preguntar password)
  scp -o BatchMode=yes -r ./exim/* "root@$SERVIDOR:${DESTINO_REMOTO}/" \
  && echo "Contenido de exim copiado con éxito a $SERVIDOR" \
  || { echo "No se pudo copiar contenido a $SERVIDOR (sin clave SSH o inaccesible)"; continue; }

  # Asegurar scripts ejecutables (no preguntar password)
  ssh -o BatchMode=yes "root@$SERVIDOR" "chmod a+x ${DESTINO_REMOTO}/dnsbl/notifica_correo_ip.bsh" \
  || { echo "No se pudieron ajustar permisos en $SERVIDOR (sin clave SSH o inaccesible)"; continue; }

  # Reiniciar Exim (no preguntar password)
  ssh -o BatchMode=yes "root@$SERVIDOR" "
    if systemctl is-active --quiet exim.service; then
      echo \"Esperando 3 segundos antes de reiniciar Exim...\"
      sleep 3
      systemctl restart exim.service && echo \"[\$(hostname)] Exim reiniciado correctamente.\"
    else
      echo \"[\$(hostname)] Exim está detenido. No se reinicia.\"
    fi
  " || { echo "No se pudo reiniciar Exim en $SERVIDOR (sin clave SSH o inaccesible)"; continue; }

  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done

