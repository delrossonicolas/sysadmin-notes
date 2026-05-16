# Este script escribe 3 lines al archivo  /opt/exim/deny_senders 

#!/bin/bash

SERVIDORES=(
aaaaaaa

)

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" 'bash -s' <<'EOF'

    # Sobrescribir /opt/exim/deny_senders con las líneas indicadas
    cat > /opt/exim/deny_senders <<EOL
vps.ovh.(ca|ne|net|us|com)
root@iosper.gov.ar
root@senasa.gov.ar
EOL

    echo "Archivo /opt/exim/deny_senders actualizado."

    # Reiniciar Exim si está activo
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "Exim reiniciado correctamente."
    else
      echo "[$(hostname)] Exim está detenido. No se reinicia."
    fi

EOF

done
