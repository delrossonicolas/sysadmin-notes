#!/bin/bash
## Verificar si el servidor tiene configuración propia- Si la tiene no hace nada
## Este script sube la carpeta entera /exim a /etc haciendo un backup de la anterior, si existe un .bkp lo pisa
## Tambien reemplaza "aaaaaaaaa" por el hostname del dedicado. 
## Crea una carpeta temporal y la sube. Reinicia exim

# Lista de servidores destino
SERVIDORES=(
sd-1040939-l
sd-1165937-l
sd-2826752-l
)

DESTINO_REMOTO="/etc/exim"
FALLIDOS=()   # acá guardamos los que fallan

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"


  # Verificar si el servidor tiene configuración propia
  HAS_CONF=$(ssh -o BatchMode=yes "$SERVIDOR" "test -f ${DESTINO_REMOTO}/.has_own_conf && echo HAS_OWN_CONF")

if [[ "$HAS_CONF" == "HAS_OWN_CONF" ]]; then
    echo "→ Servidor $SERVIDOR tiene configuración propia (.has_own_conf). Se salta."
    continue
fi

  echo "→ Servidor $SERVIDOR NO tiene configuración propia, sigo."


  # Backup remoto
  ssh -o BatchMode=yes "$SERVIDOR" "
    if [ -d ${DESTINO_REMOTO} ]; then
      cp -a ${DESTINO_REMOTO} ${DESTINO_REMOTO}.bkp
      echo 'Backup completo de /etc/exim hecho en /etc/exim.bkp.'
    else
      echo 'No existía /etc/exim, no se hizo backup.'
    fi
  " || { 
        echo "No se pudo conectar a $SERVIDOR (sin clave SSH)."
        FALLIDOS+=("$SERVIDOR")
        continue
      }

  # Crea carpeta temporal en /tmp que después borra, así reemplaza el archivo configure
  TMPDIR="/tmp/exim.$(date +%s%N)"
  mkdir -p "$TMPDIR/exim"
  cp -r ./exim/* "$TMPDIR/exim/"

  # Obtener el hostname completo desde el servidor remoto
  hostname_full=$(ssh "$SERVIDOR" 'hostname')

  # Reemplazar en el configure "vps-1337272-x.dominio.com" por el hostname
  sed -i "s/aaaaaaaaa/$hostname_full/g" "$TMPDIR/exim/configure"

  # Copiar la carpeta temporal
  scp -o BatchMode=yes -r "$TMPDIR"/exim/* "root@$SERVIDOR:${DESTINO_REMOTO}/" \
  && echo "Contenido de exim copiado con éxito a $SERVIDOR" \
  || { 
        echo "No se pudo copiar contenido a $SERVIDOR (sin clave SSH o inaccesible)"
        FALLIDOS+=("$SERVIDOR")
        rm -rf "$TMPDIR"
        continue
      }
   
  # Instalar dependencias en remoto
  ssh -o BatchMode=yes "$SERVIDOR" "yum install -y libmaxminddb libmaxminddb-devel" \
  || { 
        echo "No se pudo instalar librerías en $SERVIDOR"
        FALLIDOS+=("$SERVIDOR")
        rm -rf "$TMPDIR"
        continue
      }

  # Asegurar scripts ejecutables 
  ssh -o BatchMode=yes "root@$SERVIDOR" "chmod a+x ${DESTINO_REMOTO}/dnsbl/notifica_correo_ip.bsh" \
  || { 
        echo "No se pudieron ajustar permisos en $SERVIDOR (sin clave SSH o inaccesible)"
        FALLIDOS+=("$SERVIDOR")
        rm -rf "$TMPDIR"
        continue
      }

  # Reiniciar Exim (CentOS 6 usa 'service', no 'systemctl')
  ssh -o BatchMode=yes "$SERVIDOR" "
    if service exim status >/dev/null 2>&1; then
      echo \"Esperando 3 segundos antes de reiniciar Exim...\"
      sleep 3
      service exim restart && echo \"[\$(hostname)] Exim reiniciado correctamente.\"
    else
      echo \"[\$(hostname)] Exim está detenido o no instalado.\"
    fi
  " || { 
        echo "No se pudo reiniciar Exim en $SERVIDOR"
        FALLIDOS+=("$SERVIDOR")
        rm -rf "$TMPDIR"
        continue
      }
  
  # Limpiar los directorios temporales 
  rm -rf "$TMPDIR"
  
  echo -e "\033[1;32mCompletado para $SERVIDOR\033[0m"
done

# Resumen final
if [ ${#FALLIDOS[@]} -gt 0 ]; then
  echo -e "\n\033[1;31mServidores con error:\033[0m"
  printf '%s\n' "${FALLIDOS[@]}"
  printf '%s\n' "${FALLIDOS[@]}" > servidores_fallidos.txt
else
  echo -e "\n\033[1;32mTodos los servidores procesados con éxito.\033[0m"
fi
