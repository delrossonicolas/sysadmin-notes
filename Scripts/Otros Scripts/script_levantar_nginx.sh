## Este script detecta la flotante. Levanta el nginx si esta activada
#!/bin/bash

export PATH=$PATH:/usr/sbin:/sbin

# Verificar si la IP flotante xxxx.xxx.xxx  está en la interfaz wan0
if ip a show dev wan0 | grep -q "xxx.xxx.xxx.xxx"; then
    echo "IP flotante detectada en wan0. Iniciando nginx..."
    systemctl start nginx

    if systemctl is-active --quiet nginx; then
        echo "nginx iniciado correctamente."
    else
        echo "Error al iniciar nginx." >&2
    fi
else
    echo "No se encontró la IP flotante en wan0. No se inicia nginx."
    exit 0
fi
