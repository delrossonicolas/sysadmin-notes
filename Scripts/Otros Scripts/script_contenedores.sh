#!/bin/bash
##Este script monitorea servicios caidos

# Configura los detalles de notificación
BOT_TOKEN="xxx"
CHAT_ID="xxxxxx"

# Lista de servicios a monitorear (puedes especificar los nombres de los servicios)
SERVICES=("docs_docs-worker")

# Función para enviar notificación a Telegram
send_telegram_message() {
    local service_name="$1"
    local message="Aviso: El servicio $service_name está caído."
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"
}

# Verifica el estado de cada servicio
for service in "${SERVICES[@]}"; do
    # Obtiene el número de tareas que están en estado running
    running_tasks=$(docker service ps $service --format '{{.CurrentState}}' | grep "Running" | wc -l)

    # Si hay tareas que no están en estado running, envía una notificación
    if [ "$running_tasks" -eq 0 ]; then
        send_telegram_message $service
    fi
done
