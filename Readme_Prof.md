# Infrastructure Network Services (SAE34)

Ce projet met en place une infrastructure réseau complète utilisant Docker, comprenant des services DNS, NTP, RADIUS et VPN.

## Prérequis

- **Docker** et **Docker Compose** installés sur votre machine.
- Git (optionnel, pour cloner le dépôt).

## Installation et Démarrage

### 🍎 macOS

En raison de l'utilisation de certains ports par le système (comme le port 53), ce projet utilise une plage de ports spécifique (20000+).

1.  **Générer les certificats VPN** :
    Ouvrez un terminal à la racine du projet et exécutez :
    ```bash
    cd vpn
    chmod +x gen_certs.sh
    ./gen_certs.sh
    cd ..
    ```

2.  **Démarrer les services** :
    ```bash
    docker compose up -d --build
    ```

### 🐧 Linux

1.  **Générer les certificats VPN** :
    ```bash
    cd vpn
    chmod +x gen_certs.sh
    ./gen_certs.sh
    cd ..
    ```

2.  **Démarrer les services** :
    ```bash
    docker compose up -d --build
    ```

### 🪟 Windows

Il est recommandé d'utiliser **WSL2** ou **Git Bash** pour exécuter les scripts.

1.  **Générer les certificats VPN** :
    Ouvrez Git Bash ou votre terminal WSL dans le dossier du projet :
    ```bash
    cd vpn
    ./gen_certs.sh
    cd ..
    ```
    *Si vous n'avez pas d'outil bash, vous devrez générer les certificats OpenSSL manuellement ou installer OpenSSL pour Windows.*

2.  **Démarrer les services** :
    Ouvrez PowerShell ou CMD :
    ```powershell
    docker compose up -d --build
    ```

## Services et Configuration

Le réseau Docker est configuré sur le sous-réseau `172.28.0.0/24`.

| Service | Container IP | Host Port (Mac/Win/Linux) | Description |
|---------|--------------|---------------------------|-------------|
| **DNS** | `172.28.0.5` | `20053` (TCP/UDP) | Serveur BIND9 (Zone `lab.local`) |
| **NTP** | `172.28.0.4` | `20123` (UDP) | Serveur Chrony |
| **RADIUS**| `172.28.0.3` | `21812`, `21813` (UDP) | FreeRADIUS + PostgreSQL (Ubuntu) (`172.28.0.10`) |
| **VPN** | `172.28.0.2` | `21194` (UDP) | OpenVPN |

## Vérification

Une fois les conteneurs lancés, vous pouvez vérifier le bon fonctionnement avec les commandes suivantes :

### 1. DNS (Résolution de nom)
Depuis votre machine hôte (si `dig` est installé) :
```bash
dig @localhost -p 20053 vpn.lab.local
```
Depuis le conteneur :
```bash
docker exec dns_server dig @localhost vpn.lab.local
```

### 2. NTP (Synchronisation)
Vérifier l'état du serveur de temps :
```bash
docker exec ntp_server chronyc tracking
```

### 3. RADIUS (Authentification)
Tester une connexion RADIUS (Utilisateur: `steve`, Password: `testing`) :
```bash
docker exec radius_server radtest steve testing localhost 0 testing123
```

Tester l'authentification avec la base de données PostgreSQL (Utilisateur: `sqluser`, Password: `sqlpassword`) :
```bash
docker exec radius_server radtest sqluser sqlpassword localhost 0 testing123
```

### 4. VPN (État)
Vérifier que le serveur VPN a démarré correctement :
```bash
docker logs vpn_server
```

## Dépannage

- **Erreur "Address already in use"** : Vérifiez que les ports 20xxx ne sont pas utilisés. Vous pouvez modifier le fichier `docker-compose.yml` pour changer les mappages de ports.
- **VPN ne démarre pas** : Assurez-vous d'avoir exécuté le script `./gen_certs.sh` dans le dossier `vpn/` avant de lancer le compose. Le VPN a besoin des fichiers `.crt` et `.key`.
- **Problèmes de permissions (Linux/Mac)** : Si vous rencontrez des erreurs de permission sur les fichiers de configuration, assurez-vous que les fichiers dans `vpn/`, `dns/`, etc. sont lisibles.