# docker/Dockerfile
FROM citusdata/citus:latest

# Copiar script de inicialización
COPY ./init.sql /docker-entrypoint-initdb.d/

# Configuraciones adicionales
ENV POSTGRES_USER=spotifyuser
ENV POSTGRES_PASSWORD=spotifypass
ENV POSTGRES_DB=spotifydb