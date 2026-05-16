# Este script restaura el último backup creado y reinicia Exim -- Probado para centos 6
#!/bin/bash 

SERVIDORES=(

)

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\e[1;34m===== RESTAURANDO EN $SERVIDOR =====\e[0m"

  ssh -qt "$SERVIDOR" 'bash -s' <<'EOF'
    CONFIG="/etc/exim/configure"

    if [ ! -f "$CONFIG" ]; then
        echo "NO EXISTE /etc/exim/configure"
        exit 0
    fi

    # Buscar el último backup creado
    LAST_BACKUP=$(ls -1t ${CONFIG}_*.bak 2>/dev/null | head -n 1)

    if [ -z "$LAST_BACKUP" ]; then
        echo "NO HAY BACKUPS DISPONIBLES"
        exit 0
    fi

    echo "Backup encontrado: $LAST_BACKUP"
    cp "$LAST_BACKUP" "$CONFIG"
    echo "✔ Archivo restaurado desde el backup"

    # Reiniciar Exim según sistema operativo
    if command -v systemctl >/dev/null 2>&1; then
        echo "Reiniciando Exim con systemctl..."
        systemctl restart exim.service
    else
        echo "Reiniciando Exim con service..."
        service exim restart
    fi

EOF

  echo -e "\e[33m------------------x---------------\e[0m"
  echo
done
