#!/bin/bash

# 1. Génération de l'Autorité de Certification (CA)
# Crée la clé privée de la CA et son certificat (valide 10 ans)
openssl genrsa -out ca.key 2048
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/CN=SAE34-CA"

# 2. Génération de la clé et du certificat du Serveur
# Crée la clé privée du serveur, une demande de signature (CSR) et signe le certificat avec la CA
openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=vpn.sae34.lan"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365

# 3. Génération des paramètres Diffie-Hellman
# Indispensable pour sécuriser l'échange de clés initial
openssl dhparam -out dh.pem 2048

echo "Certificats générés avec succès dans le dossier vpn/"