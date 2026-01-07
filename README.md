# SAE34
Infrastructure Virtualisée

SUR VSCODE : 
- installer extension GitHub ou installer Github desktop sur le PC
- installer extension Docker sur VsCode

GitHub : 
Le principe :
    ● git pull : Récupérer le travail des autres.
    ● git add + git commit + git push : Enregistrer et partager votre travail.

    ⚠ Règle d'or : Toujours faire un git pull avant de commencer à coder.


Contexte : Vous êtes technicien réseau chez un opérateur.
Mission : Prototyper une stack de services réseau conteneurisés (Docker) destinée à être déployée en production sur des routeurs (MikroTik) ou des serveurs de POP.

En SAÉ (Aujourd'hui) : Tout se passe sur votre machine.
● Côté Serveur : Docker héberge l'infrastructure (NTP, DNS, Radius, DB).
● Côté Client : Votre propre OS (Windows/Linux) ou des outils de test (nslookup, radtest) simuleront les requêtes du réseau.


Rôles dans la SAE : 
● L'Intégrateur (A) : Le garant du docker-compose.yml, du VPN et du réseau.
● L'Admin Services (B) : Le responsable du DNS et du NTP.
● L'Admin Backend (C) : Le responsable du couple FreeRADIUS/ PostgreSQL


Services :

● NTP :
  - Rôle :  Garantir une horloge unique pour la corrélation des logs et la validité des certificats, les routeurs clients et tous les équipements nécessaire.
  - Challenge Technique : Un conteneur ne peut pas changer l'heure du noyau hôte par défaut. Il doit agir en relais.
  - Logiciel suggéré : Chrony. --> NTP/chrony.conf
  - Test de validation : ntpdate -q 127.0.0.1

● DNS :
  - Rôle : Resolver (Cache pour accélérer le web) + Zone Locale optionnelle (Authoritative pour sae34.lan)
  - Logiciel suggéré : BIND9.
  - Ports : Attention, le DNS utilise UDP/53 (standard) et TCP/53 (réponses > 512 octets ou transferts de zone).
  - Test de validation : dig @127.0.0.1 -p 53 google.fr

● VPN :
  - Rôle : Permettre à un administrateur de se connecter au réseau de gestion de manière chiffrée.
  - Spécificité Docker : Le conteneur a besoin de privilèges élevés (NET_ADMIN) pour créer l'interface réseau virtuelle (tun0).
  - Logiciel : OpenVPN
  - Test de validation : nc -u -v -z 127.0.0.1 1194

● AAA :
  - Rôle : Authentifier les utilisateurs (Radius) et stocker leurs données (PostgreSQL).
  - Architecture Micro-Services :
    a. Conteneur A (Cerveau) : FreeRADIUS.
    b. Conteneur B (Mémoire) : PostgreSQL
  - Le Piège : FreeRADIUS ne doit pas chercher la base de données sur localhost (sa propre machine virtuelle), mais sur le nom DNS du conteneur DB via le réseau Docker.
  - Test de validation : radtest user pass 127.0.0.1 1812 secret


Docker : 
Docker est une technologie de conteneurisation. Il permet d'isoler des applications avec leurs dépendances (bibliothèques, binaires) dans des "boîtes" appelées conteneurs.
    ● Avantage clé : La Légèreté.
        ○ VM (Machine Virtuelle) : Chaque VM a son propre OS complet (noyau + applications). C'est lourd et lent.
        ○ Conteneur Docker : Partage le noyau Linux de la machine hôte. Il n'embarque que l'application et ses bibliothèques spécifiques. C'est beaucoup plus léger et démarre en quelques secondes.
    ● Le Mot-clé : Portabilité. Un conteneur Docker fonctionne exactement de la même manière sur n'importe quelle machine (Linux, Mac, Windows avec WSL) qui a Docker installé.

Contrainte "From Scratch" :
    ● Règle du jeu : Toutes vos images doivent partir de FROM debian:trixie-slim ou de toute autre distribution linux comme ubuntu ou alpine par exemple.
    
    ● Pourquoi Trixie (Debian 13) ? C'est la version actuelle stable de debian. En tant d’administrateurs réseau, vous devez savoir préparer l'infrastructure de demain avec les paquets les plus récents.
    
    ● L'Exercice : Pas de script magique. Vous installez (apt), configurez et lancez les services vous-mêmes.

Piège du PID 1 (Foreground vs Background) :
    ● Problème : Dans un conteneur Debian de base, systemd n'existe pas. Les commandes classiques (service start) lancent le processus en arrière-plan.

    ● Conséquence : Le conteneur s'arrête immédiatement car Docker pense que le travail est fini.

    ● Solution : Chaque service doit être lancé avec une commande qui le maintient au premier plan (ex: named -g, chronyd -d, freeradius -X, postgres -D).


Volume, Réseau, Port Mapping
1. Le Réseau Interne (Bridge)
    ○ C'est quoi ? Un switch virtuel isolé créé par Docker.
    ○ Usage : Permet aux conteneurs de discuter entre eux (ex: Radius ↔ PostgreSQL).
    ○ Magie : Résolution DNS automatique par nom de service (ping postgres fonctionne   !).
2. Le Port Mapping (Exposition)
    ○ C'est quoi ? Une règle de NAT (Translation d'Adresse) entre votre PC et le conteneur.
    ○ Usage : Permet d'accéder aux services depuis votre Windows/Linux (ex: 127.0.0.1:53 → Conteneur:53).
    ○ Syntaxe : -p PortHôte:PortConteneur (ex: 8080:80).
3. Les Volumes (Persistance)
    ○ C'est quoi ? Un dossier de votre disque dur physique "monté" dans le conteneur.
    ○ Usage : Sauvegarder les données critiques (Base de données, Clés VPN).
    ○ Sans volume : Si le conteneur redémarre, tout est effacé.

