# Este script sube dos archivos notifica_correo_ip.bsh y limite.auth.exim. Creando un backup de limite.auth.exim porque notifica_correo_ip.bsh no existe y reinicia el servicio. Los archivos son distintos en compartidos y dedicados
#!/bin/bash

ARCHIVOS=(notifica_correo_ip.bsh limite.auth.exim)

# Lista de servidores destino
SERVIDORES=(

)

# Ruta remota donde se copiarán los archivos
DESTINO_REMOTO="/etc/exim/dnsbl/"

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  for ARCHIVO in "${ARCHIVOS[@]}"; do
    echo "Procesando archivo: $ARCHIVO"

    # Backup remoto si existe
    ssh "$SERVIDOR" "if [ -f ${DESTINO_REMOTO}${ARCHIVO} ]; then cp ${DESTINO_REMOTO}${ARCHIVO} ${DESTINO_REMOTO}${ARCHIVO}.bkp; echo 'Backup de $ARCHIVO hecho.'; else echo 'No existe $ARCHIVO, no se hace backup.'; fi"

    # Copiar archivo al servidor
    scp "./$ARCHIVO" "$SERVIDOR:$DESTINO_REMOTO" && echo "Archivo $ARCHIVO copiado con éxito a $SERVIDOR"
  done

  # Reiniciar Exim si está activo en el servidor remoto
  ssh "$SERVIDOR" '
    if systemctl is-active --quiet exim.service; then
      systemctl restart exim.service && echo "Exim reiniciado correctamente."
    else
      echo "['$(hostname)'] Exim está detenido. No se reinicia."
    fi
  '

  echo -e "\033[1;32m Completado para $SERVIDOR\033[0m"
  
done



