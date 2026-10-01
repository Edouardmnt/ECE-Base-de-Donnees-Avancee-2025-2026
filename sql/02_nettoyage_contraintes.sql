-- =============================================================================
-- 02 - Nettoyage des données et contraintes d'intégrité
-- =============================================================================
USE agence_location;

-- 1. Typage : les dates importées en texte deviennent de vraies DATE ---------
UPDATE location SET datef = NULL WHERE datef = '';
ALTER TABLE location
  MODIFY dated DATE,
  MODIFY datef DATE;

-- 2. Dates de fin manquantes ou incohérentes (fin <= début) ------------------
--    On génère une date de fin plausible à partir de la durée,
--    ou à défaut une durée aléatoire de 1 à 30 jours.
UPDATE location
SET datef = DATE_ADD(dated, INTERVAL IF(duree > 0, duree, FLOOR(RAND() * 30 + 1)) DAY)
WHERE datef IS NULL OR datef <= dated;

-- 3. Clés primaires ----------------------------------------------------------
ALTER TABLE proprietaire ADD PRIMARY KEY (codeP);
ALTER TABLE voiture      ADD PRIMARY KEY (Immat);
ALTER TABLE client       ADD PRIMARY KEY (CodeC);
ALTER TABLE location     ADD id INT AUTO_INCREMENT PRIMARY KEY FIRST;
ALTER TABLE location     ADD UNIQUE (numloc);

-- 4. E-mails en double : on garde le premier propriétaire, les autres passent
--    à NULL (un propriétaire ne doit pas recevoir les mails d'un autre).
--    La sous-requête agrégée est matérialisée, ce qui évite l'erreur 1093.
UPDATE proprietaire p
JOIN (
  SELECT email, MIN(codeP) AS codeP_garde
  FROM proprietaire
  WHERE email IS NOT NULL AND email <> ''
  GROUP BY email
  HAVING COUNT(*) > 1
) d ON p.email = d.email
SET p.email = NULL
WHERE p.codeP <> d.codeP_garde;

UPDATE proprietaire SET email = NULL WHERE email = '';
ALTER TABLE proprietaire ADD UNIQUE (email);

-- 5. Numéros de permis en double : deux personnes ne peuvent pas avoir le même
--    permis. Faute de savoir lequel est le bon, on les neutralise tous.
UPDATE client c
JOIN (
  SELECT permis FROM client GROUP BY permis HAVING COUNT(*) > 1
) d ON c.permis = d.permis
SET c.permis = NULL;
ALTER TABLE client ADD UNIQUE (permis);

-- 6. Clés étrangères ---------------------------------------------------------
ALTER TABLE voiture
  ADD CONSTRAINT fk_voiture_proprietaire
  FOREIGN KEY (codeP) REFERENCES proprietaire(codeP)
  ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE location
  ADD CONSTRAINT fk_location_client
  FOREIGN KEY (CodeC) REFERENCES client(CodeC)
  ON UPDATE CASCADE ON DELETE SET NULL;

ALTER TABLE location
  ADD CONSTRAINT fk_location_voiture
  FOREIGN KEY (immat) REFERENCES voiture(Immat)
  ON UPDATE CASCADE ON DELETE SET NULL;

-- 7. Contraintes de domaine (CHECK) ------------------------------------------
ALTER TABLE voiture ADD CONSTRAINT chk_places CHECK (places BETWEEN 1 AND 9);
ALTER TABLE voiture ADD CONSTRAINT chk_prixJ  CHECK (prixJ > 0);
ALTER TABLE voiture ADD CONSTRAINT chk_achatA CHECK (achatA BETWEEN 1900 AND 2026);
ALTER TABLE proprietaire ADD CONSTRAINT chk_email_format CHECK (email LIKE '%_@_%');
ALTER TABLE location ADD CONSTRAINT chk_dates CHECK (datef > dated);
