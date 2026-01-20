FROM debian:trixie-slim

RUN apt update && apt install -y \
    freeradius \
    freeradius-postgresql \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

#  configuration FreeRADIUS personnalisée
COPY raddb/ /etc/freeradius/3.0/

# Sécurité permissions
RUN chown -R freerad:freerad /etc/freeradius/3.0 \
    && chmod -R 755 /etc/freeradius/3.0

EXPOSE 1812/udp 21812/udp

CMD ["freeradius","-X"]