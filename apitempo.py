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
    elif "NON_DEFINI"==couleur:
        print("Le jour n'est pas connu.\nVous avez sûrement défini une date antérieure au début de Tempo, ou la date est supérieure à J+2")



