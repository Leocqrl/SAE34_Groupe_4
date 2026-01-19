FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y bind9 dnsutils iputils-ping && \
    apt clean

COPY named.conf /etc/bind/named.conf
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local /etc/bind/named.conf.local
COPY zones /etc/bind/zones

EXPOSE 53/udp
EXPOSE 53/tcp

CMD ["named", "-g"]
