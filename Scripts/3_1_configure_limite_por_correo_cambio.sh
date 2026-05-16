#!/bin/bash
##Este script chequea si el servidor tiene su propia config se salta, sino cambia /etc/exim/limite_por_correo y reinicia exim


SERVIDORES=(
xxxxxx
xxxxx
)

DESTINO_REMOTO="/etc/exim"
ERRORES=()   # <<< Acumulador de errores

echo "Modificando limite_por_correo en servidores..."
echo "-----------------------------------------------"

for SERVIDOR in "${SERVIDORES[@]}"; do
    echo "[$SERVIDOR] Procesando..."

    # =======================================
    # 1) Chequeo de has_own_conf
    # =======================================
    HAS_CONF=$(ssh -o BatchMode=yes -o ConnectTimeout=5 root@"$SERVIDOR" "test -f ${DESTINO_REMOTO}/.has_own_conf && echo HAS_OWN_CONF")

    if [[ "$HAS_CONF" == "HAS_OWN_CONF" ]]; then
        echo "→ Servidor $SERVIDOR tiene configuración propia (.has_own_conf). Se salta."
        echo "------------------x---------------"
        echo
        continue
    fi

    echo "→ Servidor $SERVIDOR NO tiene configuración propia, sigo."
    echo

    # =======================================
    # 2) Modificación del archivo remoto
    # =======================================
    ssh -o ConnectTimeout=5 -o BatchMode=yes root@"$SERVIDOR" '
        FILE="/etc/exim/limite_por_correo"
        TIMESTAMP=$(date +%Y%m%d_%H%M)

        # Backup con timestamp
        cp -f "$FILE" "${FILE}_${TIMESTAMP}"

        # Sobrescribir archivo con el nuevo valor
        echo "*:500" > "$FILE"

        echo "[$(hostname)] Nuevo contenido:"
        cat "$FILE"
    ' || {
        echo "[$SERVIDOR] ERROR: No se pudo modificar el archivo."
        ERRORES+=("$SERVIDOR: ERROR modificando archivo")
        echo
        continue
    }

    # =======================================
    # 3) Reiniciar Exim según sistema operativo
    # =======================================
    ssh -o BatchMode=yes -o ConnectTimeout=5 root@"$SERVIDOR" "
        if command -v systemctl >/dev/null 2>&1; then
            echo \"Reiniciando Exim con systemctl...\"
            systemctl restart exim.service
        else
            echo \"Reiniciando Exim con service...\"
            service exim restart
        fi
    " || {
        echo "[$SERVIDOR] ERROR: No se pudo reiniciar Exim."
        ERRORES+=("$SERVIDOR: ERROR reiniciando Exim")
        echo
        continue
    }

    echo "[$SERVIDOR] OK"
    echo
done

echo "-----------------------------------------------"
echo "Proceso finalizado."
echo

# ====================================================
# 🔴 RESUMEN FINAL DE ERRORES (si los hubo)
# ====================================================
if (( ${#ERRORES[@]} > 0 )); then
    echo "===== SERVIDORES CON ERRORES ====="
    for ERR in "${ERRORES[@]}"; do
        echo "⚠ $ERR"
    done
    echo "=================================="
else
    echo "✔ Todos los servidores procesados sin errores."
fi
