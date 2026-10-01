-- =============================================================================
-- 04 - Droits d'accès
-- =============================================================================
USE agence_location;

-- 1. Table applicative des accès : L = lecture, E = écriture, U = update,
--    D = delete, T = total. Lecture seule par défaut, login unique.
CREATE TABLE ACCESS (
  user_id      INT AUTO_INCREMENT PRIMARY KEY,
  login        VARCHAR(100) NOT NULL UNIQUE,
  password     VARCHAR(100) NOT NULL,
  access_level ENUM('L', 'E', 'U', 'D', 'T') NOT NULL DEFAULT 'L'
) ENGINE = InnoDB;

-- 2. Remplissage automatique
--    Clients : accès lecture, login "nom.prenom"
INSERT INTO ACCESS (login, password, access_level)
SELECT LOWER(CONCAT(Nom, '.', Prenom)), MD5(CONCAT(Nom, Prenom)), 'L'
FROM client;

--    Propriétaires ayant un e-mail valide : accès écriture, login = e-mail.
--    Ceux sans e-mail sont à recontacter par l'agence.
INSERT INTO ACCESS (login, password, access_level)
SELECT email, MD5(email), 'E'
FROM proprietaire
WHERE email IS NOT NULL;

-- ⚠ Limite assumée de l'exercice : MD5 d'une donnée connue n'est pas un vrai
--   mot de passe. En production : mot de passe aléatoire + hash lent et salé
--   (bcrypt / Argon2) côté application.

-- 3. Utilisateurs MySQL avec des droits différents
--    (mots de passe de démonstration, base locale uniquement)
CREATE USER IF NOT EXISTS 'lecteur'@'%' IDENTIFIED BY 'lecteur123';
GRANT SELECT ON agence_location.client  TO 'lecteur'@'%';
GRANT SELECT ON agence_location.voiture TO 'lecteur'@'%';

CREATE USER IF NOT EXISTS 'editeur'@'%' IDENTIFIED BY 'editeur123';
GRANT SELECT, INSERT, UPDATE ON agence_location.client   TO 'editeur'@'%';
GRANT SELECT, INSERT, UPDATE ON agence_location.location TO 'editeur'@'%';

CREATE USER IF NOT EXISTS 'admin_agence'@'%' IDENTIFIED BY 'admin123';
GRANT ALL PRIVILEGES ON agence_location.* TO 'admin_agence'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
