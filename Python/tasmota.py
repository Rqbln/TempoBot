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



ip = "192.168.1.70"  # remplacer par l'adresse IP de votre prise Tasmota
command_on = "Power%20on"
command_off = "Power%20off"
def jours_restants():
    url_Jrestants=f"https://particulier.edf.fr/services/rest/referentiel/getNbTempoDays?TypeAlerte=TEMPO"
    Jrestants = requests.get(url_Jrestants).json()
    return (Jrestants["PARAM_NB_J_BLEU"], Jrestants["PARAM_NB_J_BLANC"], Jrestants["PARAM_NB_J_ROUGE"])




def set_power():
    topic = input("Entrez le nom du topic : ")
    status = input("Voulez-vous allumer ou éteindre la prise ? (ON/OFF) : ").upper()

    if status == "ON":
        message = "1"
    elif status == "OFF":
        message = "0"
    else:
        print("Erreur : statut invalide")
        return

    command = f"mosquitto_pub -d -t cmnd/tasmota_{topic}/power -m '{message}'"

    result = subprocess.run(command, shell=True)
    if result.returncode != 0:
        print("Erreur : impossible de contrôler la prise Tasmota")
    else:
        print(f"Prise Tasmota sur le topic '{topic}' : {status}")

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


    while True:
        os.system("cls")
        color = get_tempo_color()
        colorJ1=get_tempo_colorJ1()
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
        time.sleep(30)
        ref = db.reference("/data")
        data = {"date": "{:04d}/{:02d}/{:02d}".format(now.tm_year,
                 now.tm_mon, now.tm_mday),
                "dateJ1": (date.today()+timedelta(days=1)).strftime("%Y/%m/%d"),
                "couleurJ": color,
                "couleurJ1": colorJ1,

                "Jrest_bleu":Jrestants_BLEU,
                "Jrest_blanc":Jrestants_BLANC,
                "Jrest_rouge":Jrestants_ROUGE
                }
        ref.set(data)
        os.system("cls")








if __name__ == "__main__":
    main()

