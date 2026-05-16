# Este script hace un backup y vuelve a 0 el contendio del archivo /opt/exim/deny_senders 
#!/bin/bash

# Lista de servidores destino
SERVIDORES=(

)

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" 'bash -s' <<'EOF'
  
    # Backup si existe
    
    if [ -f /opt/exim/deny_senders ]; then
      cp -f /opt/exim/deny_senders /opt/exim/deny_senders26_06_25.bkp
      truncate -s 0 /opt/exim/deny_senders
      echo "Archivo limpiado y backup creado."
    else
      echo "No existe /opt/exim/deny_senders, no se hizo nada."
      exit 1
    fi

    # Reiniciar Exim si está activo
    
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "Exim reiniciado correctamente."
    else
      echo "[$(hostname)] Exim está detenido. No se reinicia."
    fi
EOF

done
