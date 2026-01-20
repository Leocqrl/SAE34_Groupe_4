#!/bin/bash
# OpenVPN transmet le nom d'utilisateur et le mot de passe via un fichier temporaire
USER=$(head -n 1 $1)
PASS=$(tail -n 1 $1)

# Logique de test : l'utilisateur est valide si le mot de passe est "password"
if [ "$PASS" == "password" ]; then
    exit 0 # Succès
else
    exit 1 # Échec
fi