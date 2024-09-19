FROM alpine:latest

# Instalar iptables y dos2unix
RUN apk --no-cache add iptables dos2unix

# Copiar el script de configuración
COPY init-iptables.sh /init-iptables.sh

# Convertir los saltos de línea y dar permisos de ejecución al script
RUN dos2unix /init-iptables.sh && chmod +x /init-iptables.sh

# Ejecutar el script al iniciar el contenedor
CMD ["sh", "/init-iptables.sh"]
