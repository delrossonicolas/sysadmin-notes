##Este script chequea la linea del configure y la elimina
#!/bin/bash 

SERVIDORES=(
cXXX
)

ENCONTRADOS=()  # Lista para guardar los que tienen la línea

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\e[1;34m===== $SERVIDOR =====\e[0m"

  RESULTADO=$(ssh -qt "$SERVIDOR" 'bash -s' <<'EOF'
    if [ -f /etc/exim/configure ]; then
        LINEA=$(grep "return_path = " /etc/exim/configure)

        if [ -n "$LINEA" ]; then
            echo "Encontrada: $LINEA"
            # Eliminar la línea completa
            sed -i '/return_path = /d' /etc/exim/configure
            echo "→ Línea eliminada del configure"
        else
            echo "No se encontró la línea"
        fi
    else
        echo "NO EXISTE /etc/exim/configure"
    fi
EOF
  )

  echo "$RESULTADO"

  # Si contenía la línea, lo agregamos a la lista
  if echo "$RESULTADO" | grep -q "Encontrada:"; then
    ENCONTRADOS+=("$SERVIDOR")
  fi

  echo -e "\e------------------x---------------\e[0m"
  echo
done

# Mostrar resumen final
if [ "${#ENCONTRADOS[@]}" -gt 0 ]; then
  echo -e "\e[1;32mServidores donde se eliminó 'return_path = ':\e[0m"
  for S in "${ENCONTRADOS[@]}"; do
    echo "- $S"
  done
else
  echo -e "\e[1;33mNingún servidor tenía 'return_path = '\e[0m"
fi
