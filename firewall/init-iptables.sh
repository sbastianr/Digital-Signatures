#!/bin/sh

# Obtener la dirección IP del contenedor 'back' usando un ping DNS
BACK_IP=$(getent hosts api-backend | awk '{ print $1 }')

# Si la IP fue encontrada, configura iptables
if [ -n "$BACK_IP" ]; then
  echo "IP del contenedor back: $BACK_IP"

  # Redirigir todo el tráfico TCP al contenedor 'back'
  iptables -t nat -A PREROUTING -p tcp --dport 5000 -j DNAT --to-destination $BACK_IP:5000
  iptables -t nat -A POSTROUTING -p tcp -d $BACK_IP --dport 5000 -j MASQUERADE
else
  echo "No se pudo obtener la IP del contenedor back"
fi

# Mantener el contenedor en ejecución
while true; do sleep 1000; done
