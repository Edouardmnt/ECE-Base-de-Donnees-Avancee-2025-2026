-- Démo : cycle de vie d'une voiture
USE agence_location;

SELECT Immat, etat FROM voiture WHERE Immat = '11FG62';

-- 1. Nouvelle location -> la voiture passe "En location"
INSERT INTO location (numloc, CodeC, immat, duree, km, dated, datef)
VALUES ('L9999', 'C654', '11FG62', 7, 850, CURDATE(), CURDATE() + INTERVAL 7 DAY);
SELECT Immat, etat FROM voiture WHERE Immat = '11FG62';

-- 2. Une 2e location sur la même voiture est refusée par le trigger
-- INSERT INTO location (numloc, CodeC, immat, duree, km, dated, datef)
-- VALUES ('L9998', 'C100', '11FG62', 3, 120, CURDATE(), CURDATE() + INTERVAL 3 DAY);  -- ERREUR attendue

-- 3. Fin de la location -> la voiture redevient "Disponible"
UPDATE location SET dated = CURDATE() - INTERVAL 7 DAY, datef = CURDATE() WHERE numloc = 'L9999';
SELECT Immat, etat FROM voiture WHERE Immat = '11FG62';

-- 4. Tout est tracé dans l'historique
SELECT * FROM historique_etat WHERE immat = '11FG62' ORDER BY id;

-- Nettoyage
DELETE FROM location WHERE numloc = 'L9999';
