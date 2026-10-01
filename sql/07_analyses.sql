-- =============================================================================
-- 07 - Requêtes d'analyse (utilisées pour les graphiques)
-- =============================================================================
USE agence_location;

-- 1. Quels clients ont parcouru le plus de kilomètres ?
SELECT CONCAT(c.Prenom, ' ', c.Nom) AS client, SUM(l.km) AS distance
FROM client c
JOIN location l ON c.CodeC = l.CodeC
GROUP BY c.CodeC, c.Prenom, c.Nom
ORDER BY distance DESC
LIMIT 10;

-- 2. Comment se répartit le parc selon son état ?
SELECT etat, COUNT(*) AS n
FROM voiture
GROUP BY etat
ORDER BY n DESC;

-- 3. Comment évolue le nombre de locations au fil des mois (saisonnalité) ?
SELECT DATE_FORMAT(dated, '%Y-%m') AS mois, COUNT(*) AS n
FROM location
GROUP BY mois
ORDER BY mois;

-- 4. Quelles durées de location sont les plus fréquentes ?
SELECT duree, COUNT(*) AS n
FROM location
WHERE duree > 0
GROUP BY duree
ORDER BY duree;

-- 5. Quelle relation entre la durée et la distance moyenne parcourue ?
SELECT duree, ROUND(AVG(km)) AS km_moyen
FROM location
WHERE duree > 0
GROUP BY duree
ORDER BY duree;
