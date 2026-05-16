#!/bin/bash
## Dada una lista de servidores, este script borrar en el destino /root los archivos listados

SERVIDORES=(
001
002
003
)

SSH_OPTS="-o BatchMode=yes -o ConnectTimeout=10"

ARCHIVOS=(
Archivos a borrar.txt
)

RUTA="/root"   # <-- CAMBIAR

for SERVER in "${SERVIDORES[@]}"; do
    echo "===== $SERVER ====="

    ssh $SSH_OPTS root@$SERVER "
        cd $RUTA || exit 1

        echo '[INFO] Archivos a borrar:'
        ls -ld ${ARCHIVOS[*]} 2>/dev/null

        echo '[INFO] Borrando...'
        rm -rf ${ARCHIVOS[*]}

        echo '[OK] Finalizado en $SERVER'
    "

    echo ""
done
