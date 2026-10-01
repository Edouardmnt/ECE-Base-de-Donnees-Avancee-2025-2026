-- =============================================================================
-- 05 - Procédures stockées
-- =============================================================================
USE agence_location;

ALTER TABLE location
  ADD COLUMN note TINYINT NULL,
  ADD COLUMN avis VARCHAR(30) NULL;

DELIMITER $$

-- Note de 1 à 5 selon le kilométrage et la durée de la location
CREATE PROCEDURE attribuer_notes()
BEGIN
  UPDATE location
  SET note = CASE
    WHEN km IS NULL OR duree IS NULL OR duree <= 1 THEN NULL
    WHEN km > 1000 AND duree > 50 THEN 5
    WHEN km > 500  AND duree > 20 THEN 4
    WHEN km > 100  AND duree > 7  THEN 3
    WHEN km <= 100 AND duree > 3  THEN 2
    ELSE 1
  END;
END$$

-- Avis textuel déduit de la note
CREATE PROCEDURE attribuer_avis()
BEGIN
  UPDATE location
  SET avis = CASE note
    WHEN 5 THEN 'Très satisfait'
    WHEN 4 THEN 'Satisfait'
    WHEN 3 THEN 'Assez satisfait'
    WHEN 2 THEN 'Peu satisfait'
    WHEN 1 THEN 'Insatisfait'
    ELSE 'Non évalué'
  END;
END$$

-- Synthèse des locations d'un client : durée totale, nombre de véhicules
-- différents et note moyenne. Exemple : CALL analyse_client('C654');
CREATE PROCEDURE analyse_client(IN p_CodeC VARCHAR(4))
BEGIN
  SELECT
    p_CodeC                  AS `Code client`,
    IFNULL(SUM(duree), 0)    AS `Durée totale (jours)`,
    COUNT(DISTINCT immat)    AS `Nb véhicules différents`,
    ROUND(AVG(note), 2)      AS `Moyenne des notes`
  FROM location
  WHERE CodeC = p_CodeC;
END$$

DELIMITER ;

CALL attribuer_notes();
CALL attribuer_avis();
