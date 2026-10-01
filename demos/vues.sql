-- Démo : modifiabilité des vues
USE agence_location;

-- V_client contient un agrégat : la mise à jour est refusée
-- UPDATE V_client SET distance = 0 WHERE CodeC = 'C654';   -- ERREUR attendue

-- V_Client55 est modifiable : un client de 50 ans est inséré dans la table client...
INSERT INTO V_Client55 (CodeC, Prenom, Nom, age) VALUES ('C999', 'Louis', 'Test', 50);
SELECT * FROM V_Client55 WHERE CodeC = 'C999';   -- ... mais n'apparaît pas dans la vue
SELECT * FROM V_client   WHERE CodeC = 'C999';   -- il est bien présent ici

-- Avec WITH CHECK OPTION, la même insertion est refusée
-- INSERT INTO V_Client55_strict (CodeC, Prenom, Nom, age) VALUES ('C998', 'Lou', 'Test', 50);  -- ERREUR attendue

DELETE FROM client WHERE CodeC = 'C999';
