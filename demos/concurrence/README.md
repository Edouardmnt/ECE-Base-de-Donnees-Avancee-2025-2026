# Accès concurrents

Ouvrir **deux terminaux** connectés à la base :

```bash
docker compose exec db mysql -uroot -proot agence_location
```

puis exécuter les blocs dans l'ordre indiqué (S1 = session 1, S2 = session 2).

## 1. Mise à jour perdue

| Étape | Session 1 | Session 2 |
|---|---|---|
| 1 | `START TRANSACTION;` `SELECT compteur FROM voiture WHERE Immat='11FG62';` | |
| 2 | | `START TRANSACTION;` `SELECT compteur FROM voiture WHERE Immat='11FG62';` |
| 3 | `UPDATE voiture SET compteur = 100180 WHERE Immat='11FG62';` | |
| 4 | | `UPDATE voiture SET compteur = 100200 WHERE Immat='11FG62';` → bloqué |
| 5 | `COMMIT;` | l'UPDATE passe, puis `COMMIT;` |

Chaque session écrit une valeur calculée **à partir de sa propre lecture** : la dernière écriture écrase la première, une des deux mises à jour est perdue.

**Solution** : verrouiller la ligne dès la lecture avec `SELECT ... FOR UPDATE`, et écrire de façon relative :

```sql
START TRANSACTION;
SELECT compteur FROM voiture WHERE Immat = '11FG62' FOR UPDATE;  -- la 2e session attend ici
UPDATE voiture SET compteur = compteur + 100 WHERE Immat = '11FG62';
COMMIT;
```

Lancé dans les deux sessions, le compteur augmente bien de 200 au total.

## 2. Lecture sale

| Étape | Session 1 | Session 2 |
|---|---|---|
| 1 | `START TRANSACTION;` `UPDATE voiture SET compteur = compteur + 200 WHERE Immat='11FG62';` | |
| 2 | | `SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;` `SELECT compteur FROM voiture WHERE Immat='11FG62';` → voit +200 |
| 3 | `ROLLBACK;` | la valeur lue n'a jamais existé |

En `READ UNCOMMITTED`, la session 2 lit une donnée non validée. Avec le niveau par défaut d'InnoDB (`REPEATABLE READ`), la même lecture renvoie l'ancienne valeur.

Dans le projet, la table était d'abord en **MyISAM**, un moteur sans transactions : chaque requête est validée immédiatement, `ROLLBACK` n'a aucun effet et l'isolation n'existe pas. Le passage à **InnoDB** a rendu les transactions, les verrous de ligne et les niveaux d'isolation possibles.
