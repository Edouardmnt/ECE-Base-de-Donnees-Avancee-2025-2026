-- =============================================================================
-- 00 - Schéma "brut", tel qu'obtenu après import des CSV dans phpMyAdmin :
--      dates stockées en texte, pas de clés ni de contraintes.
--      Tout est corrigé dans 02_nettoyage_contraintes.sql.
-- =============================================================================
CREATE DATABASE IF NOT EXISTS agence_location
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE agence_location;

CREATE TABLE proprietaire (
  codeP  VARCHAR(4),
  nom    VARCHAR(50),
  ville  VARCHAR(50),
  email  VARCHAR(100)
) ENGINE = InnoDB;

CREATE TABLE voiture (
  Immat    VARCHAR(10),
  marque   VARCHAR(30),
  modele   VARCHAR(30),
  codeP    VARCHAR(4),
  places   INT,
  prixJ    DECIMAL(6,2),
  achatA   INT,
  compteur INT
) ENGINE = InnoDB;

CREATE TABLE client (
  CodeC   VARCHAR(4),
  Prenom  VARCHAR(50),
  Nom     VARCHAR(50),
  age     INT,
  permis  VARCHAR(20),
  ville   VARCHAR(50)
) ENGINE = InnoDB;

CREATE TABLE location (
  numloc  VARCHAR(6),
  CodeC   VARCHAR(4),
  immat   VARCHAR(10),
  duree   INT,
  km      INT,
  dated   VARCHAR(10),   -- importé en texte depuis le CSV
  datef   VARCHAR(10)    -- idem, avec des valeurs manquantes
) ENGINE = InnoDB;
