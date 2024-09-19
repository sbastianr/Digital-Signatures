# Install Operating system and dependencies
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y lsof 
RUN apt-get update --fix-missing
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback python3 dos2unix
RUN apt-get clean

ENV DEBIAN_FRONTEND=dialog
ENV PUB_HOSTED_URL=https://pub.flutter-io.cn
ENV FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

# download Flutter SDK from Flutter Github repo
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

# Set flutter environment path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run flutter doctor
RUN flutter doctor

# Crear un nuevo usuario
RUN useradd -ms /bin/bash flutteruser

# Cambiar los permisos del directorio Flutter para el usuario no root
USER root
RUN mkdir -p /app/
RUN chown -R flutteruser:flutteruser /app/

# Copiar archivos y ajustar permisos
COPY . /app/
RUN chown -R flutteruser:flutteruser /app/
RUN chmod +x /app/server/server.sh

# Cambiar de nuevo al usuario no root
USER flutteruser

# Forzar Git a usar HTTP/1.1
RUN git config --global http.version HTTP/1.1

# Añadir el directorio Flutter a la lista de directorios seguros en Git
RUN git config --global --add safe.directory /usr/local/flutter

# Cambiar los permisos del directorio Flutter para el usuario no root
USER root
RUN chown -R flutteruser:flutteruser /usr/local/flutter

# Cambiar de nuevo al usuario no root
USER flutteruser

# Enable flutter web
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

# Copy files to container and build
RUN dos2unix /app/server/server.sh
WORKDIR /app/
RUN flutter build web

# Record the exposed port
EXPOSE 9000

# Start the web server
ENTRYPOINT ["/app/server/server.sh"]