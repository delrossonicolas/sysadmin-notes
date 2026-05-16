 # Este script borra los configure anteriores a 2025 en todos los compartidos 
#!/bin/bash

SERVIDORES=(
0101
0202
)

for SERVIDOR in "${SERVIDORES[@]}"; do
  echo -e "\033[1;33mProcesando servidor: $SERVIDOR\033[0m"

  ssh "$SERVIDOR" 'bash -s' <<'EOF'

    echo "[INFO] Archivos actuales en /etc/exim/:"
    ls -l --time-style=long-iso /etc/exim/configure* 2>/dev/null || echo "No hay archivos configure*"

    echo -e "\033[1;33m[INFO] Eliminando archivos configure* modificados antes de 2025 (excepto 'configure')...\033[0m"
    find /etc/exim/ -maxdepth 1 -type f -name 'configure*' ! -name 'configure' ! -newermt '2025-01-01' -delete

    echo "[INFO] Archivos restantes tras la eliminación:"
    ls -l --time-style=long-iso /etc/exim/configure* 2>/dev/null || echo "No hay archivos configure*"
    
EOF

done
