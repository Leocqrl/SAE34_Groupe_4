FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y bind9 dnsutils iputils-ping && \
    apt clean

COPY config/named.conf /etc/bind/named.conf
COPY config/named.conf.options /etc/bind/named.conf.options
COPY config/named.conf.local /etc/bind/named.conf.local
COPY config/zones /etc/bind/zones

EXPOSE 20053/udp
EXPOSE 20053/tcp

CMD ["named", "-g"]
