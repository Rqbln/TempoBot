import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import datetime

import schedule
import time




cred = credentials.Certificate("tempobot-406fc-firebase-adminsdk-o6bkq-a1ab9cdc76.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tempobot-406fc-default-rtdb.europe-west1.firebasedatabase.app/'
})

ref = db.reference("/data")


def ChoisirJour():

    now = datetime.datetime.now()

    semaine_dico = {
        0: "Lundi",
        1: "Mardi",
        2: "Mercredi",
        3: "Jeudi",
        4: "Vendredi",
        5: "Samedi",
        6: "Dimanche"
    }

    jourSemaine = semaine_dico[now.weekday()]

    date = "{} {:%d-%m-%Y}".format(jourSemaine, now)

    parties = date.split("-")
    Annee = parties[-1]
    Mois = parties[-2]
    Jour = parties[0].split(" ")[-1]

    url = "https://particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant={}-{}-{}".format(Annee,Mois,Jour)

    reponse = requests.get(url).json()
    couleurJ = reponse["couleurJourJ"]
    couleurJ1 = reponse["couleurJourJ1"]
    if "TEMPO_ROUGE" == couleurJ:
        print("Le jour est rouge")
    elif "TEMPO_BLEU" == couleurJ:
        print("Le jour est bleu")
    elif "TEMPO_BLANC" == couleurJ:
        print("Le jour est blanc")
    else:
        print(
            "Le jour n'est pas connu.\nVous avez sûrement défini une date antérieure au début de Tempo, ou la date est supérieure à J+2")
    print(date)
    heure = str(datetime.datetime.now())
    data = {"couleurJ": couleurJ, "couleurJ1": couleurJ1, "Date": date}
    ref.set(data)



ChoisirJour()

schedule.every().day.at("22:00").do(ChoisirJour)

while True:
    schedule.run_pending()
    time.sleep(1)

def configPrise():
    heures = [[0, 0], [0, 0], [0, 0]]
    couleurs = ["rouges", "blancs", "bleus"]
    print("Configuration de la prise connectée (1 pour On, 2 pour Off)")
    for i in range(3):

        print("Jours", couleurs[i])
        heures[i][0] = input("Heures pleines :")
        if "1" == heures[i][0]:
            print("ON")
        elif "0" == heures[i][0]:
            print("OFF")

        heures[i][1] = input("Heures creuses :")
        if "1" == heures[i][1]:
            print("ON")
        elif "0" == heures[i][1]:
            print("OFF")

    print("\nRésumé :")
    for i in range(3):
        print("Jours", couleurs[i], ":")
        print("Heures pleines :", "ON" if heures[i][0] == "1" else "OFF")
        print("Heures creuses :", "ON" if heures[i][1] == "1" else "OFF")


def tasmotaAPI():
    ip = "Entrez l'ip de la prise :"
    commandON = "Power1"
    commandOFF = "Power0"
    url = "http://{ip}/cm?cmnd=Status%200"

    try:
        response = requests.get(url, timeout=5)
        status = response.json()
        if "POWER" in status:
            state = status["POWER"]
            if state == "ON":
                response = requests.get(f"http://{ip}/cm?cmnd={commandOFF}")
                print(response.text)
            elif state == "OFF":
                response = requests.get(f"http://{ip}/cm?cmnd={commandON}")
                print(response.text)
        else:
            print("La prise est connectée, mais impossible de récupérer son état.")
    except requests.exceptions.RequestException as e:
        print("La prise n'est pas connectée.")


if __name__ == "__main__":
    main()
