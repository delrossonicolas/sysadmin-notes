##Esta guia es para explicar el procedimiento de elimiar una linea en el exim de todos los servidores: 
##Sacamos los servidores vps cloud con su respectivo sistema operativo y los dejamos en esta salida.txt
##for i in lista servers; do
##  for j in alma8-uefi-fz centos7-64-fz alma8-uefi-mysql57-fz centos6-64-fz centos5-64-fz; do
##    ssh -qt "$i" "/scripts/list_instances_by_image $j"
##  done
##done > servidores.txt


# Este script chequea una linea del archivo configure
#!/bin/bash

SERVIDORES=(
dattasites1
dattasites2
)

ENCONTRADOS=()  # Lista para guardar los que tienen la línea

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\e[1;34m===== $SERVIDOR =====\e[0m"

  # Ejecutar SSH en modo batch para evitar pedir password
  RESULTADO=$(ssh -o BatchMode=yes -o ConnectTimeout=5 -qt "$SERVIDOR" 'bash -s' <<'EOF'
    if [ -f /etc/exim/configure ]; then
        grep "return_path = " /etc/exim/configure || echo "No se encontró la línea"
    else
        echo "NO EXISTE /etc/exim/configure"
    fi
EOF
  )

  SSH_EXIT=$?   # Capturar el código de salida del SSH

  # Si SSH falla por password o conexión → saltar al siguiente
  if [ $SSH_EXIT -ne 0 ]; then
    echo -e "\e[1;31mError de conexión (o requiere password). Se salta este servidor.\e[0m"
    echo -e "\e------------------x---------------\e[0m"
    echo
    continue
  fi

  echo "$RESULTADO"

  # Si contiene "return_path = ", lo agregamos a la lista
  if echo "$RESULTADO" | grep -q "return_path = "; then
    ENCONTRADOS+=("$SERVIDOR")
  fi

  echo -e "\e------------------x---------------\e[0m"
  echo
done

# Mostrar resumen final
if [ "${#ENCONTRADOS[@]}" -gt 0 ]; then
  echo -e "\e[1;32mServidores que contienen 'return_path = ':\e[0m"
  for S in "${ENCONTRADOS[@]}"; do
    echo "- $S"
  done
else
  echo -e "\e[1;33mNingún servidor contiene 'return_path = '\e[0m"
fi
