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

ref = db.reference("/data")


ip = "192.168.1.70"  # remplacer par l'adresse IP de votre prise Tasmota
command_on = "Power%20on"
command_off = "Power%20off"

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

"""
def configPrise():
    heures = [[0, 0], [0, 0], [0, 0]]
    couleurs = ["rouge", "blanc", "bleu"]
    print("Configuration de la prise connectée (1 pour On, 0 pour Off)")
    for i in range(3):

        print("\nCouleur :", couleurs[i])
        heures[i][0] = input("Heures pleines : ")
        if "1" == heures[i][0]:
            print("ON")
        elif "0" == heures[i][0]:
            print("OFF")

        heures[i][1] = input("Heures creuses : ")
        if "1" == heures[i][1]:
            print("ON")
        elif "0" == heures[i][1]:
            print("OFF")

    print("\nRésumé :")
    for i in range(3):
        print("Jours", couleurs[i], ":")
        print("Heures pleines :", "ON" if heures[i][0] == "1" else "OFF")
        print("Heures creuses :", "ON" if heures[i][1] == "1" else "OFF")
"""


def main():
    heures_rouges = [[0, 0], [0, 0]]
    heures_blanches = [[0, 0], [0, 0]]
    heures_bleues = [[0, 0], [0, 0]]
    heures = None
    os.system("clear")
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
                set_power("ON")
            else:
                print("Heures : creuses")
                set_power("OFF")
        elif int(heures[0][0]) == 1 and int(heures[0][1]) == 0:
            if heure_actuelle >= 6:
                set_power("ON")
            else:
                set_power("OFF")
        elif int(heures[0][0]) == 0 and int(heures[0][1]) == 1:
            if heure_actuelle < 6 or (heure_actuelle == 22 and minute_actuelle == 0) or heure_actuelle >= 22:
                print("Heures : creuses")
                set_power("ON")
            else:
                print("Heures : pleines")
                set_power("OFF")
        else:
            set_power("OFF")

        # Afficher l'heure

        print("Heure : {}:{}:{}".format(now.tm_hour, now.tm_min, now.tm_sec))
        time.sleep(5)
        os.system("clear")

        # Calculer le temps restant avant la prochaine vérification de la couleur
        time_left = next_color_check - time.time()

        if time_left > 0:
            while True:
                color = get_tempo_color()
                if color == "TEMPO_ROUGE":
                    print("Couleur : rouge")
                    heures = heures_rouges
                elif color == "TEMPO_BLANC":
                    print("Couleur : blanc")
                    heures = heures_blanches
                elif color == "TEMPO_BLEU":
                    print("Couleur : bleu")
                    heures = heures_bleues
                else:
                    wait_for_new_day()
                    continue

                now = time.localtime()
                heure_actuelle = now.tm_hour
                minute_actuelle = now.tm_min

                if int(heures[0][0]) == 1 and int(heures[0][1]) == 1:
                    if (heure_actuelle >= 6 and heure_actuelle < 22) or (heure_actuelle == 22 and minute_actuelle == 0):
                        set_power("ON")
                    else:
                        set_power("OFF")
                elif int(heures[0][0]) == 1 and int(heures[0][1]) == 0:
                    if heure_actuelle >= 6:
                        set_power("ON")
                    else:
                        set_power("OFF")
                elif int(heures[0][0]) == 0 and int(heures[0][1]) == 1:
                    if heure_actuelle < 6 or (heure_actuelle == 22 and minute_actuelle == 0) or heure_actuelle >= 22:
                        set_power("ON")
                    else:
                        set_power("OFF")
                else:
                    set_power("OFF")

                next_check = datetime.datetime.now

    data = {"Date": next_check,"couleurJ": color, "couleurJ1": colorJ1,"IP_plug":ip,"RED_status":heures_rouges,"WHITE_status":heures_blanches,"BLUE_status":heures_bleues}
    ref.set(data)



if __name__ == "__main__":
    main()

