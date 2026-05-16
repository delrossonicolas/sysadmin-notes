# Este script chequea si una particion esta montada o no y lo monta si corresponde, escribe un log.
#!/bin/bash

export PATH=$PATH:/usr/sbin:/sbin

# Verificar si el servidor tiene la IP flotante
if ! ip a show dev wan0 | grep -q "wan0:1"; then
#    echo "Servidor sin la IP flotante."
    exit 0
fi

# Verificar si el punto de montaje existe para public
if ! mountpoint -q /home/envialosimple/mfs/public; then
    echo "El punto de montaje /public no existe. Montando..."
    mfsmount /home/envialosimple/mfs/public
    if [ $? -eq 0 ]; then
        echo "Montaje de /public exitoso."
    else
        echo "Error al montar /public." >&2
    fi
fi


# Verificar si el punto de montaje existe para filestorage
if ! mountpoint -q /home/envialosimple/mfs/filestorage; then
    echo "El punto de montaje /filestorage no existe. Montando..."
    mfsmount /home/envialosimple/mfs/filestorage
    if [ $? -eq 0 ]; then
        echo "Montaje de /filestorage exitoso."
    else
        echo "Error al montar /filestorage." >&2
    fi
fi
