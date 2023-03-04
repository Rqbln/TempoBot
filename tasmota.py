import requests
import datetime
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




def set_power(status):
    if status == "ON":
        response = requests.get(f"http://{ip}/cm?cmnd={command_on}")
    elif status == "OFF":
        response = requests.get(f"http://{ip}/cm?cmnd={command_off}")
    else:
        print("Erreur : statut invalide")
        return

    if response.status_code != 200:
        print("Erreur : impossible de contrôler la prise Tasmota")
    else:
        print(f"Prise Tasmota : {status}")

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


    couleurs = ["rouge", "blanc", "bleu"]
    print("Configuration de la prise connectée (1 pour On, 0 pour Off)")
    for i in range(3):
        print("\nCouleur :", couleurs[i])
        if i == 0:
            heures = heures_rouges
        elif i == 1:
            heures = heures_blanches
        else:
            heures = heures_bleues

        heures[0][0] = input("Heures pleines : ")
        heures[0][1] = input("Heures creuses : ")

    print("\nRésumé :")
    for i in range(3):
        print("Jours", couleurs[i], ":")
        if i == 0:
            heures = heures_rouges
        elif i == 1:
            heures = heures_blanches
        else:
            heures = heures_bleues
        print("Heures pleines :", "ON" if heures[0][0] == "1" else "OFF")
        print("Heures creuses :", "ON" if heures[0][1] == "1" else "OFF")

    next_color_check = time.time()

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



        if int(heures[0][0]) == 1 and int(heures[0][1]) == 1:
            if (heure_actuelle >= 6 and heure_actuelle < 22) or (heure_actuelle == 22 and minute_actuelle == 0):
                print("Heures : pleines")
                statut = 1
                set_power("ON")
            else:
                print("Heures : creuses")
                statut = 0
                set_power("OFF")
        elif int(heures[0][0]) == 1 and int(heures[0][1]) == 0:
            if heure_actuelle >= 6:
                statut = 1
                set_power("ON")
            else:
                statut = 0
                set_power("OFF")
        elif int(heures[0][0]) == 0 and int(heures[0][1]) == 1:
            if heure_actuelle < 6 or (heure_actuelle == 22 and minute_actuelle == 0) or heure_actuelle >= 22:
                print("Heures : creuses")
                statut = 1
                set_power("ON")
            else:
                print("Heures : pleines")
                statut = 0
                set_power("OFF")
        else:
            statut = 0
            set_power("OFF")

        # Afficher l'heure

        print("Heure : {}:{}:{}".format(now.tm_hour, now.tm_min, now.tm_sec))
        time.sleep(5)
        ref = db.reference("/data")
        data = {"date": "{:04d}/{:02d}/{:02d}".format(now.tm_year,
                 now.tm_mon, now.tm_mday),
                "dateJ1": "{:04d}/{:02d}/{:02d}".format(now.tm_year,
                now.tm_mon, now.tm_mday + 1),
                "heure": "{:02d}:{:02d}:{:02d}".format(now.tm_hour,
                now.tm_min, now.tm_sec),
                "couleurJ": color,
                "couleurJ1": colorJ1,
                "IP_plug": ip,
                "RED_pleine": heures_rouges[0][0],
                "RED_creuse": heures_rouges[0][1],
                "WHITE_pleine": heures_blanches[0][0],
                "WHITE_creuse": heures_blanches[0][1],
                "BLUE_pleine": heures_bleues[0][0],
                "BLUE_creuse": heures_bleues[0][1],
                "Jrest_bleu":Jrestants_BLEU,
                "Jrest_blanc":Jrestants_BLANC,
                "Jrest_rouge":Jrestants_ROUGE
                }
        ref.set(data)
        os.system("cls")








if __name__ == "__main__":
    main()

