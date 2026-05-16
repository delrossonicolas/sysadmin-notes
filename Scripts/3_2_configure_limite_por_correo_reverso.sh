#!/bin/bash

SERVIDORES=(
vps-908032-x
)

DESTINO_REMOTO="/etc/exim"

echo "Restaurando limite_por_correo desde su backup..."
echo "-------------------------------------------------"

for SERVIDOR in "${SERVIDORES[@]}"; do
    echo "[$SERVIDOR] Procesando restauración..."

    # ===============================
    # 1) Chequeo de has_own_conf
    # ===============================
    HAS_CONF=$(ssh -o BatchMode=yes -o ConnectTimeout=5 root@"$SERVIDOR" "test -f ${DESTINO_REMOTO}/.has_own_conf && echo HAS_OWN_CONF")

    if [[ "$HAS_CONF" == "HAS_OWN_CONF" ]]; then
        echo "→ Servidor $SERVIDOR tiene configuración propia (.has_own_conf). Se salta."
        echo "------------------x---------------"
        echo
        continue
    fi

    echo "→ Servidor $SERVIDOR NO tiene configuración propia, sigo."
    echo

    # ===============================
    # 2) Restaurar archivo desde backup
    # ===============================
    ssh -o BatchMode=yes -o ConnectTimeout=5 root@"$SERVIDOR" '
        FILE="/etc/exim/limite_por_correo"

        # Buscar el último backup disponible
        LAST_BACKUP=$(ls -1t ${FILE}_* 2>/dev/null | head -n 1)

        if [[ -z "$LAST_BACKUP" ]]; then
            echo "[ERROR] No se encontró ningún backup para restaurar."
            exit 1
        fi

        echo "→ Restaurando desde: $LAST_BACKUP"
        cp -f "$LAST_BACKUP" "$FILE"

        echo "→ Contenido actual restaurado:"
        cat "$FILE"
    ' || {
        echo "[$SERVIDOR] ERROR: Falló la restauración del archivo."
        echo
        continue
    }

    # ===============================
    # 3) Reiniciar Exim
    # ===============================
    ssh -o BatchMode=yes -o ConnectTimeout=5 root@"$SERVIDOR" "
        if command -v systemctl >/dev/null 2>&1; then
            echo \"Reiniciando Exim con systemctl...\"
            systemctl restart exim.service && echo \"Exim reiniciado correctamente.\"
        else
            echo \"Reiniciando Exim con service...\"
            service exim restart && echo \"Exim reiniciado correctamente.\"
        fi
    " || {
        echo "[$SERVIDOR] ERROR: No se pudo reiniciar Exim."
        echo
        continue
    }

    echo "[$SERVIDOR] Restauración completada correctamente."
    echo
done

echo "-------------------------------------------------"
echo "Proceso finalizado."
