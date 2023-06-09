import requests
from datetime import date, timedelta
import subprocess
import time
import os

import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

cred = credentials.Certificate("tempobot-406fc-firebase-adminsdk-o6bkq-a1ab9cdc76.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tempobot-406fc-default-rtdb.europe-west1.firebasedatabase.app/'
})

def jours_restants():
    url_Jrestants = "https://particulier.edf.fr/services/rest/referentiel/getNbTempoDays?TypeAlerte=TEMPO"
    Jrestants = requests.get(url_Jrestants).json()
    return (Jrestants["PARAM_NB_J_BLEU"], Jrestants["PARAM_NB_J_BLANC"], Jrestants["PARAM_NB_J_ROUGE"])

def get_tempo_color():
    now = time.localtime()
    url = f"https://particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant={now.tm_year}-{now.tm_mon}-{now.tm_mday}"
    response = requests.get(url).json()
    return response["couleurJourJ"]

def get_tempo_colorJ1():
    now = time.localtime()
    url = f"https://particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant={now.tm_year}-{now.tm_mon}-{now.tm_mday}"
    response = requests.get(url).json()
    return response["couleurJourJ1"]

def wait_for_new_day():
    while True:
        color = get_tempo_color()
        if color != "TEMPO_BLANC" and color != "TEMPO_BLEU" and color != "TEMPO_ROUGE":
            time.sleep(60)
        else:
            break



def process_user_data(users_data,previous_data):
    # Vérifier s'il y a des utilisateurs
    if users_data is not None:
        # Parcourir tous les utilisateurs
        for user_id, user_data in users_data.items():
            # Exclure les clés indésirables
            if user_id not in ['Jrest_blanc', 'Jrest_bleu', 'Jrest_rouge', 'couleurJ', 'couleurJ1', 'date', 'dateJ1']:
                print("Utilisateur:", user_id)

                # Vérifier le type de user_data
                if isinstance(user_data, int):
                    print("Donnée utilisateur:", user_data)
                    continue

                # Vérifier si l'utilisateur a des prises
                if 'prises' in user_data:
                    prises = user_data['prises']

                    # Parcourir toutes les prises de l'utilisateur
                    for prise_id, prise_data in prises.items():
                        print("Prise:", prise_id)

                        # Vérifier si les données ont changé
                        if prise_data != previous_data.get(user_id, {}).get(prise_id):
                            print("Les données ont changé !")

                        # Accéder aux données spécifiques de chaque prise
                        creuses_blanc = prise_data.get('creuses_blanc')
                        creuses_bleu = prise_data.get('creuses_bleu')
                        creuses_rouge = prise_data.get('creuses_rouge')
                        isOn = prise_data.get('isOn')
                        nom = prise_data.get('nom')
                        pleines_blanc = prise_data.get('pleines_blanc')
                        pleines_bleu = prise_data.get('pleines_bleu')
                        pleines_rouge = prise_data.get('pleines_rouge')

                        print("creuses_blanc:", creuses_blanc)
                        print("creuses_bleu:", creuses_bleu)
                        print("creuses_rouge:", creuses_rouge)
                        print("isOn:", isOn)
                        print("nom:", nom)
                        print("pleines_blanc:", pleines_blanc)
                        print("pleines_bleu:", pleines_bleu)
                        print("pleines_rouge:", pleines_rouge)

                        # Mettre à jour les données précédentes
                        if user_id not in previous_data:
                            previous_data[user_id] = {}
                        previous_data[user_id][prise_id] = prise_data

                else:
                    print("Aucune prise pour cet utilisateur.")
    else:
        print("Aucun utilisateur trouvé.")

# ...

# Déclarer une variable pour stocker les données précédentes









def main():
    heures_rouges = [[0, 0], [0, 0]]
    heures_blanches = [[0, 0], [0, 0]]
    heures_bleues = [[0, 0], [0, 0]]
    heures = None
    os.system("cls")

    Jrestants_BLEU, Jrestants_BLANC, Jrestants_ROUGE = jours_restants()
    print("\nIl reste", Jrestants_BLEU, "jours bleus")
    print("Il reste", Jrestants_BLANC, "jours blancs")
    print("Il reste", Jrestants_ROUGE, "jours rouges")

    ref_data = db.reference("/data")
    ref_users = db.reference("/data/users")

    while True:
        os.system("cls")
        color = get_tempo_color()
        colorJ1 = get_tempo_colorJ1()
        if color == "TEMPO_ROUGE":
            print("\n\nCouleur : rouge")
            heures = heures_rouges
        elif color == "TEMPO_BLANC":
            print("\n\nCouleur : blanc")
            heures = heures_blanches
        elif color == "TEMPO_BLEU":
            print("\n\nCouleur : bleu")
            heures = heures_bleues
        else:
            wait_for_new_day()
            continue

        now = time.localtime()
        heure_actuelle = now.tm_hour
        minute_actuelle = now.tm_min

        # Afficher l'heure
        print("Heure : {}:{}:{}".format(now.tm_hour, now.tm_min, now.tm_sec))
        time.sleep(5)

        data = {
            "date": "{:04d}/{:02d}/{:02d}".format(now.tm_year, now.tm_mon, now.tm_mday),
            "dateJ1": (date.today() + timedelta(days=1)).strftime("%Y/%m/%d"),
            "couleurJ": color,
            "couleurJ1": colorJ1,
            "Jrest_bleu": Jrestants_BLEU,
            "Jrest_blanc": Jrestants_BLANC,
            "Jrest_rouge": Jrestants_ROUGE
        }

        ref_data.update(data)

        previous_data = {}

        # Dans la fonction main():
        users_data = ref_users.get()
        process_user_data(users_data,previous_data)
        os.system("cls")

#regarder le statut de la prise actuelle et le statut quel doit avoir

if __name__ == "__main__":
    main()
