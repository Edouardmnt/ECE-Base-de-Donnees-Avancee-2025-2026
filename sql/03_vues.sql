-- =============================================================================
-- 03 - Vues
-- =============================================================================
USE agence_location;

-- Distance totale parcourue par chaque client, y compris ceux sans location
-- (LEFT JOIN + IFNULL). Cette vue contient un agrégat : elle n'est donc PAS
-- modifiable (un UPDATE ... SET distance = ... est refusé).
CREATE OR REPLACE VIEW V_client AS
SELECT c.CodeC, c.Prenom, c.Nom, c.age,
       IFNULL(SUM(l.km), 0) AS distance
FROM client c
LEFT JOIN location l ON c.CodeC = l.CodeC
GROUP BY c.CodeC, c.Prenom, c.Nom, c.age;

-- Clients de plus de 55 ans. Vue simple sur une seule table : elle est
-- modifiable. Sans WITH CHECK OPTION, on peut y insérer un client de 50 ans :
-- il est ajouté à la table client mais n'apparaît pas dans la vue.
-- (cf. demos/vues.sql)
CREATE OR REPLACE VIEW V_Client55 AS
SELECT CodeC, Prenom, Nom, age, permis
FROM client
WHERE age > 55;

-- Variante "pour aller plus loin" : avec WITH CHECK OPTION, la même insertion
-- est refusée, car la ligne ne respecterait pas le filtre de la vue.
CREATE OR REPLACE VIEW V_Client55_strict AS
SELECT CodeC, Prenom, Nom, age, permis
FROM client
WHERE age > 55
WITH CHECK OPTION;
