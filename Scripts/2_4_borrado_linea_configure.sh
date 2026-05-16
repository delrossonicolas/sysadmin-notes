## Este script hace lo siguiente: chequea si tiene configuracion propia (si la tiene, salta), hace un backup y cambia la linea del configure 'return path =' Validando por ssh
#!/bin/bash 

SERVIDORES=(
xxxxxxxxx
xxxxxxxxxxx
)

DESTINO_REMOTO="/etc/exim"    
SIN_ACCESO=()                 

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\e[1;34m===== $SERVIDOR =====\e[0m"

  # ============================
  # 0) Chequeo si puedo entrar sin password
  # ============================
  ssh -o BatchMode=yes -o ConnectTimeout=5 "$SERVIDOR" "echo ok" >/dev/null 2>&1
  if [[ $? -ne 0 ]]; then
      echo "No puedo acceder a $SERVIDOR sin contraseña. Se salta."
      SIN_ACCESO+=("$SERVIDOR")
      echo -e "\e------------------x---------------\e[0m"
      echo
      continue
  fi

  # ============================
  # 1) Chequeo de has_own_conf
  # ============================
  HAS_CONF=$(ssh -o BatchMode=yes "$SERVIDOR" "test -f ${DESTINO_REMOTO}/.has_own_conf && echo HAS_OWN_CONF")

  if [[ "$HAS_CONF" == "HAS_OWN_CONF" ]]; then
      echo "→ Servidor $SERVIDOR tiene configuración propia (.has_own_conf). Se salta."
      echo -e "\e------------------x---------------\e[0m"
      echo
      continue
  fi

  echo "→ Servidor $SERVIDOR NO tiene configuración propia, sigo."
  echo

  # =====================================
  # 2) Backup y cambios
  # =====================================
  ssh -qt "$SERVIDOR" 'bash -s' <<'EOF'
    CONFIG="/etc/exim/configure"

    if [ ! -f "$CONFIG" ]; then
        echo "NO EXISTE /etc/exim/configure"
        exit 0
    fi

    # Backup antes de modificar
    FECHA=$(date +"%Y%m%d_%H%M")
    BACKUP="${CONFIG}_${FECHA}.bak"

    cp "$CONFIG" "$BACKUP"
    echo "Backup creado: $BACKUP"

    LINEA=$(grep "return_path = " "$CONFIG")

    if [ -z "$LINEA" ]; then
        echo "No se encontró la línea"
        exit 0
    fi

    echo "Encontrada: $LINEA"
    sed -i '/return_path = /d' "$CONFIG"
    echo "→ Línea eliminada del configure"

    # Reiniciar Exim según sistema operativo
    if command -v systemctl >/dev/null 2>&1; then
        echo "Reiniciando Exim con systemctl..."
        systemctl restart exim.service
    else
        echo "Reiniciando Exim con service..."
        service exim restart
    fi
EOF

  echo -e "\e------------------x---------------\e[0m"
  echo
done

# =====================================
# 3) Mostrar servidores sin acceso
# =====================================
if [[ ${#SIN_ACCESO[@]} -gt 0 ]]; then
    echo -e "\n\e[1;31mServidores que pidieron contraseña (sin acceso SSH sin clave):\e[0m"
    for S in "${SIN_ACCESO[@]}"; do
        echo " - $S"
    done
else
    echo -e "\nTodos los servidores permitieron acceso sin contraseña."
fi
