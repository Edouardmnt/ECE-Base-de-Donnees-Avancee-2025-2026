-- Démo : droits d'accès. Se connecter avec chaque utilisateur, par exemple :
--   docker compose exec db mysql -ulecteur -plecteur123 agence_location

-- lecteur : SELECT autorisé sur client et voiture uniquement
SELECT COUNT(*) FROM client;                                   -- OK
-- UPDATE client SET age = age + 1 WHERE CodeC = 'C654';       -- refusé

-- editeur : SELECT / INSERT / UPDATE sur client et location, pas de DELETE
-- UPDATE client SET ville = 'Paris' WHERE CodeC = 'C654';     -- OK
-- DELETE FROM client WHERE CodeC = 'C654';                    -- refusé

-- admin_agence : tous les droits, et peut les transmettre (WITH GRANT OPTION)
