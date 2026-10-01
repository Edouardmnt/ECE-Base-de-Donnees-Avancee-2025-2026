"""Génère sql/01_donnees_brutes.sql : un jeu de données FICTIF, volontairement
imparfait (dates en texte, dates de fin manquantes, e-mails et permis en double),
pour rejouer l'étape de nettoyage du projet."""
import random
from datetime import date, timedelta
from pathlib import Path

random.seed(42)

PRENOMS = ["Louis", "Emma", "Hugo", "Jade", "Lucas", "Léa", "Gabriel", "Chloé", "Arthur", "Manon",
           "Jules", "Inès", "Adam", "Camille", "Nathan", "Sarah", "Paul", "Alice", "Tom", "Lina",
           "Noah", "Zoé", "Ethan", "Rose", "Léo", "Anna", "Raphaël", "Eva", "Victor", "Julia"]
NOMS = ["Martin", "Bernard", "Dubois", "Thomas", "Robert", "Richard", "Petit", "Durand", "Leroy", "Moreau",
        "Simon", "Laurent", "Lefebvre", "Michel", "Garcia", "David", "Bertrand", "Roux", "Vincent", "Fournier",
        "Morel", "Girard", "André", "Mercier", "Dupont", "Lambert", "Bonnet", "François", "Martinez", "Legrand"]
VILLES = ["Paris", "Lyon", "Marseille", "Lille", "Nantes", "Bordeaux", "Toulouse", "Rennes"]
MODELES = [("Renault", "Clio", 5), ("Peugeot", "208", 5), ("Citroën", "C3", 5), ("Renault", "Trafic", 9),
           ("Peugeot", "5008", 7), ("Toyota", "Yaris", 5), ("Volkswagen", "Golf", 5), ("Tesla", "Model 3", 5),
           ("Dacia", "Jogger", 7), ("Fiat", "500", 4), ("Mercedes", "Vito", 8), ("BMW", "Série 1", 5)]

def q(v):
    if v is None:
        return "NULL"
    if isinstance(v, (int, float)):
        return str(v)
    return "'" + str(v).replace("'", "''") + "'"

def insert(table, cols, rows):
    out = [f"INSERT INTO {table} ({', '.join(cols)}) VALUES"]
    out.append(",\n".join("  (" + ", ".join(q(v) for v in r) + ")" for r in rows) + ";")
    return "\n".join(out)

# --- Propriétaires (avec 2 e-mails en double) --------------------------------
proprietaires = []
for i in range(12):
    nom = NOMS[(i * 7) % 30]
    email = f"{nom.lower()}.{i}@mail.fr"
    proprietaires.append([f"P{i+1:02d}", nom, random.choice(VILLES), email])
proprietaires[5][3] = proprietaires[2][3]     # doublon d'e-mail
proprietaires[9][3] = proprietaires[2][3]     # doublon d'e-mail
proprietaires[11][3] = ""                     # e-mail manquant

# --- Voitures ----------------------------------------------------------------
voitures = []
for i in range(25):
    marque, modele, places = random.choice(MODELES)
    immat = f"{random.randint(10, 99)}{random.choice('ABCDEFGHJKLMNP')}{random.choice('ABCDEFGHJKLMNP')}{random.randint(10, 99)}"
    voitures.append([immat, marque, modele, proprietaires[i % 12][0], places,
                     random.choice([35, 42, 49, 55, 65, 79, 95, 120]),
                     random.randint(2012, 2025), random.randint(5000, 180000)])
voitures[0][0] = "11FG62"   # la voiture utilisée dans les démonstrations du rapport
voitures[0][7] = 100180

# --- Clients (noms uniques, 2 permis en double) ------------------------------
clients = []
for i in range(40):
    prenom, nom = PRENOMS[i % 30], NOMS[(i * 11 + i // 30) % 30]
    clients.append([f"C{100 + i * 13:03d}", prenom, nom, random.randint(19, 78),
                    f"{random.randint(10**11, 10**12 - 1)}", random.choice(VILLES)])
clients[7][0] = "C654"      # client analysé dans le rapport
clients[20][4] = clients[3][4]   # doublon de permis
clients[31][4] = clients[3][4]   # doublon de permis

# --- Locations (dates en texte, certaines dates de fin manquantes) -----------
locations = []
debut = date(2024, 1, 1)
for i in range(160):
    c = random.choice(clients)[0]
    v = random.choice(voitures)[0]
    # saisonnalité : plus de locations l'été
    mois = random.choices(range(24), weights=[3, 3, 4, 5, 6, 9, 12, 12, 7, 5, 4, 5] * 2)[0]
    dated = debut + timedelta(days=mois * 30.4 + random.randint(0, 27))
    duree = random.choice([1, 2, 3, 4, 5, 7, 7, 10, 14, 21, 30, 45, 60, 85])
    km = int(duree * random.uniform(15, 90)) + random.randint(0, 80)
    datef = (dated + timedelta(days=duree)).isoformat()
    if i % 17 == 0:
        datef = None          # date de fin manquante
    elif i % 23 == 0:
        datef = dated.isoformat()   # date de fin = date de début (incohérent)
    locations.append([f"L{1000 + i}", c, v, duree, km, dated.isoformat(), datef])

sql = ["-- Données FICTIVES générées par scripts/generer_donnees.py (seed 42).",
       "-- Elles contiennent volontairement des défauts corrigés dans 02_nettoyage_contraintes.sql.",
       "USE agence_location;", "",
       insert("proprietaire", ["codeP", "nom", "ville", "email"], proprietaires), "",
       insert("voiture", ["Immat", "marque", "modele", "codeP", "places", "prixJ", "achatA", "compteur"], voitures), "",
       insert("client", ["CodeC", "Prenom", "Nom", "age", "permis", "ville"], clients), "",
       insert("location", ["numloc", "CodeC", "immat", "duree", "km", "dated", "datef"], locations), ""]
Path(__file__).resolve().parent.parent.joinpath("sql", "01_donnees_brutes.sql").write_text("\n".join(sql), encoding="utf-8")
print("OK")
