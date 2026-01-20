#!/bin/bash

# 1. Configurer iptables pour le NAT (Masquage)
# Cela permet aux clients VPN de sortir sur le réseau pop-net avec l'IP du serveur
iptables -t nat -A POSTROUTING -s 172.28.0.0/24 -o eth0 -j MASQUERADE

# 2. Lancer OpenVPN au PREMIER PLAN (Indispensable pour Docker) [cite: 217]
# On utilise --config pour pointer vers votre fichier
exec openvpn --config /etc/openvpn/server.conf