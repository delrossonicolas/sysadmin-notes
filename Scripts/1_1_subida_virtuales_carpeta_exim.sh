 #!/bin/bash
## Este script hace un backup, hace una carpeta temporal donde reemplaza el hostname, sube, hace ejecutable y reinicia exim
##Preserva permisos de archivos existentes -- Funcional
# Lista de servidores destino
SERVIDORES=(
xxxxxx
)

# Ruta remota donde se copiaran los archivos
DESTINO_REMOTO="/etc/exim"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

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

  # Obtener hostname remoto
  hostname_full=$(ssh "$SERVIDOR" 'cat /etc/hostname')
  hostname_short=${hostname_full%%.*}
#  hostname_base=${hostname_short::-1}

  # Reemplazar en el configure "c138" por el hostname
  sed -i "s/c138/$hostname_short/g" "$TMPDIR/exim/configure"
  sed -i "s/c138/$hostname_short/g" "$TMPDIR/exim/hostname"

  # Copiar la carpeta temporal
  scp -o BatchMode=yes -r "$TMPDIR"/exim/* "root@$SERVIDOR:${DESTINO_REMOTO}/" \
  && echo "Contenido de exim copiado con éxito a $SERVIDOR" \
  || { 
        echo "No se pudo copiar contenido a $SERVIDOR (sin clave SSH o inaccesible)"
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
      
  # Reiniciar Exim
  ssh -o BatchMode=yes "$SERVIDOR" "
    if systemctl is-active --quiet exim.service; then
      echo \"Esperando 3 segundos antes de reiniciar Exim...\"
      sleep 3
      systemctl restart exim.service && echo \"[\$(hostname)] Exim reiniciado correctamente.\"
    else
      echo \"[\$(hostname)] Exim está detenido. No se reinicia.\"
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
