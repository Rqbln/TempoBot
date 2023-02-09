import requests

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


def config():
    REDP=input("CONFIGURATION POUR LES JOURS ROUGES HEURES PLEINES (on or off)\n")
    if "on"==REDP:
        print('allumer')
    elif"off"==REDP:
        print("éteintre")

    REDC = input("CONFIGURATION POUR LES JOURS ROUGES HEURES CREUSES (on or off)\n")
    if "on" == REDC:
        print('allumer')
    elif "off" == REDC:
        print("éteintre")

    WHITEP=input("CONFIGURATION POUR LES JOURS BLANCS HEURES PLEINES (on or off)\n")
    if "on"==WHITEP:
        print('allumer')
    elif"off"==WHITEP:
        print("éteintre")

    WHITEC = input("CONFIGURATION POUR LES JOURS BLANCS HEURES CREUSES (on or off)\n")
    if "on" == WHITEC:
        print('allumer')
    elif "off" == WHITEC:
        print("éteintre")


    BLUEP=input("CONFIGURATION POUR LES JOURS BLEUS HEURES PLEINES (on or off)\n")
    if "on"==BLUEP:
        print('allumer')
    elif"off"==BLUEP:
        print("éteintre")

    BLUEP = input("CONFIGURATION POUR LES JOURS BLEUS HEURES CREUSES (on or off)\n")
    if "on" == BLUEP:
        print('allumer')
    elif "off" == BLUEP:
        print("éteintre")

config()

def apitasmota():
    ip ="entrer ip"
    commandON="Power1"
    commandOFF="Power0"
    url="http://{ip}/cm?cmnd=Status%200"

    try:
        response = requests.get(status_url, timeout=5)
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
            print("Impossible de récupérer l'état de la prise.")
    except requests.exceptions.RequestException as e:
        print("La prise est indisponible.")