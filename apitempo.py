import requests
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
cred = credentials.Certificate("D:\GITHUB\TempoBot\tempobot-406fc-firebase-adminsdk-o6bkq-a1ab9cdc76.json")
firebase_admin.initialize_app(cred)


ref = db.reference("/data")

def ChoisirJour():
    Annee = int(input("Année : "))
    Mois = int(input("Mois : "))
    Jour = int(input("Jour : "))

    url = "https://particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant={}-{}-{}".format(Annee,Mois,Jour)

    reponse = requests.get(url).json()
    couleur = reponse["couleurJourJ"]
    if "TEMPO_ROUGE"==couleur:
        print("Le jour est rouge")
    elif "TEMPO_BLEU"==couleur:
        print("Le jour est bleu")
    elif "TEMPO_BLANC"==couleur:
        print("Le jour est blanc")
    else:
        print("Le jour n'est pas connu.\nVous avez sûrement défini une date antérieure au début de Tempo, ou la date est supérieure à J+2")
    data = {"couleur": couleur}
    ref.set(data)


ChoisirJour()


def configPrise():
    heures=[[0, 0],[0, 0],[0, 0]]
    couleurs=["rouges","blancs","bleus"]
    print("Configuration de la prise connectée (1 pour On, 2 pour Off)")
    for i in range (3):

        print("Jours",couleurs[i])
        heures[i][0]=input("Heures pleines :")
        if "1"==heures[i][0]:
            print("ON")
        elif"0"==heures[i][0]:
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
    ip ="Entrez l'ip de la prise :"
    commandON="Power1"
    commandOFF="Power0"
    url="http://{ip}/cm?cmnd=Status%200"

    try:
        response = requests.get(url, timeout=5)
        status = response.json()
        if "POWER" in status:
            state = status["POWER"]
            if state == "ON":
                response = requests.get(f"http://{ip}/cm?cmnd={commandOFF}")
                print(response.text)
            elif (state == "OFF"):
                response = requests.get(f"http://{ip}/cm?cmnd={commandON}")
                print(response.text)
        else:
            print("La prise est connectée, mais impossible de récupérer son état.")
    except requests.exceptions.RequestException as e:
        print("La prise n'est pas connectée.")