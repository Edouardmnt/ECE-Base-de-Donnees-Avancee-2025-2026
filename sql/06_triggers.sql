-- =============================================================================
-- 06 - État des véhicules et triggers
-- =============================================================================
USE agence_location;

ALTER TABLE voiture
  ADD COLUMN etat ENUM('Disponible', 'En location', 'En réparation', 'Indisponible')
  NOT NULL DEFAULT 'Disponible';

-- Historique des changements d'état (traçabilité)
CREATE TABLE historique_etat (
  id           INT AUTO_INCREMENT PRIMARY KEY,
  immat        VARCHAR(10) NOT NULL,
  ancien_etat  VARCHAR(20),
  nouvel_etat  VARCHAR(20),
  date_change  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (immat) REFERENCES voiture(Immat) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

DELIMITER //

-- Avant une nouvelle location : la voiture doit être disponible,
-- puis elle passe automatiquement "En location".
CREATE TRIGGER trg_verif_voiture_avant_location
BEFORE INSERT ON location
FOR EACH ROW
BEGIN
  DECLARE v_etat VARCHAR(20);

  SELECT etat INTO v_etat FROM voiture WHERE Immat = NEW.immat;

  IF v_etat IS NULL OR v_etat <> 'Disponible' THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Cette voiture n''est pas disponible pour la location.';
  END IF;

  UPDATE voiture SET etat = 'En location' WHERE Immat = NEW.immat;
END //

-- Quand une location est terminée (date de fin atteinte),
-- la voiture redevient disponible.
CREATE TRIGGER trg_voiture_disponible_apres_location
AFTER UPDATE ON location
FOR EACH ROW
BEGIN
  IF NEW.datef <= CURDATE() THEN
    UPDATE voiture SET etat = 'Disponible'
    WHERE Immat = NEW.immat AND etat = 'En location';
  END IF;
END //

-- Chaque changement d'état d'une voiture est historisé
CREATE TRIGGER trg_historique_etat_voiture
AFTER UPDATE ON voiture
FOR EACH ROW
BEGIN
  IF NOT (OLD.etat <=> NEW.etat) THEN
    INSERT INTO historique_etat (immat, ancien_etat, nouvel_etat)
    VALUES (NEW.Immat, OLD.etat, NEW.etat);
  END IF;
END //

DELIMITER ;

-- État initial du parc (données fictives) : quelques véhicules au garage.
-- Ces mises à jour passent déjà par le trigger d'historique.
UPDATE voiture SET etat = 'En réparation' WHERE Immat IN (
  SELECT Immat FROM (SELECT Immat FROM voiture WHERE Immat <> '11FG62' ORDER BY Immat LIMIT 3) t
);
UPDATE voiture SET etat = 'Indisponible' WHERE Immat IN (
  SELECT Immat FROM (SELECT Immat FROM voiture WHERE Immat <> '11FG62' ORDER BY Immat DESC LIMIT 1) t
);
