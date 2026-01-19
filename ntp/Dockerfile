FROM debian:trixie-slim

RUN apt-get update && apt-get install -y chrony && rm -rf /var/lib/apt/lists/*

COPY chrony.conf /etc/chrony/chrony.conf

EXPOSE 123/udp

CMD ["/usr/sbin/chronyd", "-d", "-s", "-f", "/etc/chrony/chrony.conf"]
