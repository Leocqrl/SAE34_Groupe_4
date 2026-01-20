FROM debian:latest

RUN apt-get update && apt-get install -y openvpn iptables && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/openvpn/scripts /var/log/openvpn

COPY server.conf /etc/openvpn/server.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY auth.sh /etc/openvpn/scripts/auth.sh

COPY dh.pem /etc/openvpn/dh.pem
COPY ca.crt /etc/openvpn/ca.crt
COPY server.crt /etc/openvpn/server.crt
COPY server.key /etc/openvpn/server.key

# Droits d'exécution
RUN chmod +x /usr/local/bin/entrypoint.sh /etc/openvpn/scripts/auth.sh

WORKDIR /etc/openvpn/

EXPOSE 1194/udp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
