# Este script agrega una linea al archivo  /opt/exim/deny_senders sin hacer backup ya que estaba vacio el archivo

#!/bin/bash

SERVIDORES=(
c
)


for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" 'bash -s' <<'EOF'

    # Escribir la línea en el archivo (sobrescribe cualquier contenido anterior)
    echo 'vps.ovh.(ca|ne|net|us|com)' > /opt/exim/deny_senders
    echo "Línea escrita en /opt/exim/deny_senders"

    # Reiniciar Exim si está activo
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "Exim reiniciado correctamente."
    else
      echo "[$(hostname)] Exim está detenido. No se reinicia."
    fi

EOF

done
