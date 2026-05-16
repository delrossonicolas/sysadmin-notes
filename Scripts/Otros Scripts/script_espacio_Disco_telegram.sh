##Este script monitorea espacio en disco

BOT_TOKEN="xx"  # Reemplaza con tu token de bot
CHAT_ID="xxx"  # Reemplaza con tu ID de chat
ALERT=85 # Espacio minimo para realizar la alerta
PARTITION="/dev/sda3"
HOSTNAME=$(hostname)
df -H | grep -w "$PARTITION" | awk '{ print $5 " " $1 }' | while read -r output;
do
  echo "$output"
  usep=$(echo "$output" | awk '{ print $1}' | cut -d'%' -f1 )
  partition=$(echo "$output" | awk '{ print $2 }' )
  if [ $usep -ge $ALERT ]; then
    message="Advertencia: El espacio en la partición $partition está al $usep% de su capacidad. En la máquina $HOSTNAME"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" -d chat_id="$CHAT_ID" -d text="$message"
  fi
done
