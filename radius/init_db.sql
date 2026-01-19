-- -- Création de l'utilisateur pour RADIUS
-- CREATE USER radius WITH PASSWORD 'radiuspass';

-- -- Création de la base de données
-- CREATE DATABASE radius;

-- \c radius

-- -- Attribution des droits
-- GRANT ALL PRIVILEGES ON DATABASE radius TO radius;

-- CREATE TABLE radcheck (
--     id SERIAL PRIMARY KEY,
--     username VARCHAR(64),
--     attribute VARCHAR(64),
--     op CHAR(2),
--     value VARCHAR(253)
-- );

-- INSERT INTO radcheck (username, attribute, op, value) VALUES
-- ('sqluser', 'Cleartext-Password', ':=', 'sqlpassword')
-- , ('steve', 'Cleartext-Password', ':=', 'testing')
-- ON CONFLICT DO NOTHING;

-- 1. Création de l'utilisateur
-- (On vérifie s'il existe déjà pour éviter les erreurs au redémarrage)
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = 'radius') THEN
    CREATE USER radius WITH PASSWORD 'radiuspass';
  END IF;
END $$;

-- 2. Création de la base
-- Note : On ne peut pas faire CREATE DATABASE dans un bloc IF/ELSE simple
-- Docker ne lancera ce script que si le dossier /var/lib/postgresql/data est vide.
CREATE DATABASE radius;
GRANT ALL PRIVILEGES ON DATABASE radius TO radius;

-- 3. BASKULEMENT SUR LA BASE RADIUS (TRÈS IMPORTANT)
\c radius

-- 4. Création de la table DANS la base radius
CREATE TABLE radcheck (
    id SERIAL PRIMARY KEY,
    username VARCHAR(64) NOT NULL,
    attribute VARCHAR(64) NOT NULL,
    op CHAR(2) NOT NULL DEFAULT '==',
    value VARCHAR(253) NOT NULL
);

-- 5. Droits sur la table
GRANT ALL PRIVILEGES ON TABLE radcheck TO radius;
GRANT USAGE, SELECT ON SEQUENCE radcheck_id_seq TO radius;

-- 6. Insertion des données
INSERT INTO radcheck (username, attribute, op, value) 
VALUES ('steve', 'Cleartext-Password', ':=', 'testing'), ('sqluser', 'Cleartext-Password', ':=', 'sqlpassword');