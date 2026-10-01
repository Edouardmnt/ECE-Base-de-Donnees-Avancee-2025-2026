"""Exécute les requêtes d'analyse (sql/07_analyses.sql) et enregistre les
graphiques dans docs/img/.

    pip install -r analyses/requirements.txt
    python analyses/graphiques.py

Connexion configurable par variables d'environnement :
DB_HOST (localhost), DB_PORT (3306), DB_USER (root), DB_PASSWORD (root).
"""
import os
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pymysql
from matplotlib.ticker import MaxNLocator

SORTIE = Path(__file__).resolve().parent.parent / "docs" / "img"
BLEU, ENCRE, ENCRE_2, GRILLE = "#2a78d6", "#0b0b0b", "#52514e", "#e6e5e1"

plt.rcParams.update({
    "font.size": 11, "axes.edgecolor": GRILLE, "axes.labelcolor": ENCRE_2,
    "xtick.color": ENCRE_2, "ytick.color": ENCRE_2, "axes.titlecolor": ENCRE,
    "axes.titleweight": "bold", "axes.titlesize": 13, "axes.titlelocation": "left",
    "axes.spines.top": False, "axes.spines.right": False,
    "figure.facecolor": "#fcfcfb", "axes.facecolor": "#fcfcfb",
})


def requete(conn, sql):
    with conn.cursor() as cur:
        cur.execute(sql)
        return cur.fetchall()


def finir(fig, ax, nom, axe_grille="y"):
    (ax.xaxis if axe_grille == "x" else ax.yaxis).set_major_locator(MaxNLocator(integer=True))
    ax.grid(axis=axe_grille, color=GRILLE, linewidth=0.8)
    ax.set_axisbelow(True)
    fig.tight_layout()
    fig.savefig(SORTIE / nom, dpi=150)
    plt.close(fig)
    print("→", SORTIE / nom)


def main():
    SORTIE.mkdir(parents=True, exist_ok=True)
    conn = pymysql.connect(
        host=os.getenv("DB_HOST", "localhost"), port=int(os.getenv("DB_PORT", 3306)),
        user=os.getenv("DB_USER", "root"), password=os.getenv("DB_PASSWORD", "root"),
        database="agence_location", charset="utf8mb4",
    )

    # 1. Top 10 des clients par distance parcourue
    rows = requete(conn, """
        SELECT CONCAT(c.Prenom, ' ', c.Nom), SUM(l.km) AS d
        FROM client c JOIN location l ON c.CodeC = l.CodeC
        GROUP BY c.CodeC, c.Prenom, c.Nom ORDER BY d DESC LIMIT 10""")[::-1]
    fig, ax = plt.subplots(figsize=(8, 4.5))
    barres = ax.barh([r[0] for r in rows], [int(r[1]) for r in rows], color=BLEU, height=0.6)
    ax.bar_label(barres, labels=[f"{int(r[1]):,} km".replace(",", " ") for r in rows],
                 padding=4, color=ENCRE_2, fontsize=9)
    ax.set_title("Top 10 des clients par distance parcourue")
    ax.set_xlabel("Kilomètres cumulés")
    finir(fig, ax, "1_distance_par_client.png", "x")

    # 2. Répartition du parc par état
    rows = requete(conn, "SELECT etat, COUNT(*) n FROM voiture GROUP BY etat ORDER BY n")
    fig, ax = plt.subplots(figsize=(8, 3.2))
    barres = ax.barh([r[0] for r in rows], [r[1] for r in rows], color=BLEU, height=0.55)
    ax.bar_label(barres, padding=4, color=ENCRE_2, fontsize=10)
    ax.set_title("Répartition du parc automobile par état")
    ax.set_xlabel("Nombre de véhicules")
    finir(fig, ax, "2_etat_du_parc.png", "x")

    # 3. Locations par mois
    rows = requete(conn, """SELECT DATE_FORMAT(dated, '%Y-%m') m, COUNT(*)
                            FROM location GROUP BY m ORDER BY m""")
    fig, ax = plt.subplots(figsize=(9, 3.8))
    ax.plot([r[0] for r in rows], [r[1] for r in rows], color=BLEU, linewidth=2,
            marker="o", markersize=5)
    ax.set_title("Nombre de locations par mois")
    ax.set_ylabel("Locations")
    ax.set_ylim(bottom=0)
    ax.set_xticks(range(0, len(rows), 3), [rows[i][0] for i in range(0, len(rows), 3)])
    finir(fig, ax, "3_locations_par_mois.png")

    # 4. Distribution des durées
    rows = requete(conn, "SELECT duree, COUNT(*) FROM location WHERE duree > 0 GROUP BY duree ORDER BY duree")
    fig, ax = plt.subplots(figsize=(8, 3.8))
    ax.bar([str(r[0]) for r in rows], [r[1] for r in rows], color=BLEU, width=0.65)
    ax.set_title("Distribution des durées de location")
    ax.set_xlabel("Durée (jours)")
    ax.set_ylabel("Locations")
    finir(fig, ax, "4_durees.png")

    # 5. Kilométrage moyen selon la durée
    rows = requete(conn, "SELECT duree, AVG(km) FROM location WHERE duree > 0 GROUP BY duree ORDER BY duree")
    fig, ax = plt.subplots(figsize=(8, 3.8))
    ax.plot([r[0] for r in rows], [float(r[1]) for r in rows], color=BLEU, linewidth=2,
            marker="o", markersize=6)
    ax.set_title("Kilométrage moyen selon la durée de location")
    ax.set_xlabel("Durée (jours)")
    ax.set_ylabel("Km moyens")
    ax.set_ylim(bottom=0)
    finir(fig, ax, "5_km_selon_duree.png")

    conn.close()


if __name__ == "__main__":
    main()
