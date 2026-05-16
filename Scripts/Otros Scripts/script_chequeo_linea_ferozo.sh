# Este script chequea una linea del /opt/panel/data/config y la guarda en un archivo 
#!/bin/bash 

SERVIDORES=(
lista
)

ARCHIVO_SALIDA="mal_configurados.txt"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\e[1;34m===== $SERVIDOR =====\e[0m"

  if ssh "$SERVIDOR" 'bash -s' <<'EOF'
    if [ -f /opt/panel/data/config ]; then
        VALOR=$(grep "^maxemailsperhour=" /opt/panel/data/config | cut -d= -f2)
        if [ "$VALOR" != "2000" ]; then
            echo "[WARN] Valor incorrecto: maxemailsperhour=$VALOR"
            exit 99
        else
            echo "maxemailsperhour=2000"
        fi
    else
        echo "NO EXISTE /opt/panel/data/config"
        exit 98
    fi
EOF
  then
    echo -e "\e[1;32m[OK] Comando ejecutado correctamente en $SERVIDOR\e[0m"
  else
    echo -e "\e[1;31m[ERROR] Configuración incorrecta o archivo faltante en $SERVIDOR\e[0m"
    echo "$SERVIDOR" >> "$ARCHIVO_SALIDA"
  fi

  echo
done

echo -e "\n\e[1;33mServidores con configuración incorrecta guardados en $ARCHIVO_SALIDA\e[0m"

 
