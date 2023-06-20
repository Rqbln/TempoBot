import os
import sys
import time
import requests
import subprocess
from datetime import date, timedelta
import discord
import asyncio
from firebase_admin import credentials
from firebase_admin import db
import firebase_admin

# Initialization de Firebase
cred = credentials.Certificate("tempobot-406fc-firebase-adminsdk-o6bkq-a1ab9cdc76.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tempobot-406fc-default-rtdb.europe-west1.firebasedatabase.app/'
})

# Initialization de Discord
intents = discord.Intents.default()
intents.members = True  # Activer l'intent des membres
client = discord.Client(intents=intents)

ip = "192.168.1.70"  # remplacer par l'adresse IP de votre prise Tasmota
command_on = "Power%20on"
command_off = "Power%20off"


def jours_restants():
    url_Jrestants = "https://particulier.edf.fr/services/rest/referentiel/getNbTempoDays?TypeAlerte=TEMPO"
    Jrestants = requests.get(url_Jrestants).json()
    return Jrestants["PARAM_NB_J_BLEU"], Jrestants["PARAM_NB_J_BLANC"], Jrestants["PARAM_NB_J_ROUGE"]


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


def heure_creux_plein():
    heure_actuelle = time.localtime()
    if heure_actuelle.tm_hour >= 6 and heure_actuelle.tm_hour < 22:
        return "pleines"
    else:
        return "creuses"


def wait_for_new_day():
    while True:
        color = get_tempo_color()
        if color != "TEMPO_BLANC" and color != "TEMPO_BLEU" and color != "TEMPO_ROUGE":
            time.sleep(60)
        else:
            break


def recup_val_statutJ():
    ref = db.reference('/data')
    data = ref.get()

    if 'couleurJ' in data and 'Pleines_creuses' in data:
        couleurJ = data['couleurJ']
        creuses = data['Pleines_creuses']

        # Afficher les valeurs récupérées
        print("couleurJ:", couleurJ)
        print("creuses:", creuses)

        return couleurJ, creuses
    else:
        print("Les données n'existent pas dans la base de données.")
        return None, None


def process_user_data(users_data, previous_data):
    # Vérifier s'il y a des utilisateurs
    valeur = True
    couleurJ, creuses = recup_val_statutJ()

    if users_data is not None:
        # Parcourir tous les utilisateurs
        for user_id, user_data in users_data.items():
            # Exclure les clés indésirables
            if user_id not in ['Jrest_blanc', 'Jrest_bleu', 'Jrest_rouge', 'couleurJ', 'couleurJ1', 'date', 'dateJ1',
                               'Pleines_creuses']:
                print("Utilisateur:", user_id)

                # Vérifier le type de user_data
                if isinstance(user_data, dict):
                    # Vérifier si l'utilisateur a des prises
                    if 'prises' in user_data:
                        prises = user_data['prises']

                        # Parcourir toutes les prises de l'utilisateur
                        for prise_id, prise_data in prises.items():
                            print("Prise:", prise_id)
                            # Récupérer les valeurs de la prise en fonction de l'état du Tempo et de l'heure creuse/pleine
                            if creuses == 'pleines':
                                if couleurJ == 'TEMPO_BLEU':
                                    valeur = prise_data.get('pleines_bleu')
                                elif couleurJ == 'TEMPO_BLANC':
                                    valeur = prise_data.get('pleines_blanc')
                                elif couleurJ == 'TEMPO_ROUGE':
                                    valeur = prise_data.get('pleines_rouge')
                            else:  # creuses == 'creuses'
                                if couleurJ == 'TEMPO_BLEU':
                                    valeur = prise_data.get('creuses_bleu')
                                elif couleurJ == 'TEMPO_BLANC':
                                    valeur = prise_data.get('creuses_blanc')
                                elif couleurJ == 'TEMPO_ROUGE':
                                    valeur = prise_data.get('creuses_rouge')
                            # Vérifier si les données ont changé

                            if valeur is True:
                                # Allumer la prise
                                prise_data.update({'isOn': 'true'})

                                commande_allumer = f'mosquitto_pub -d -t cmnd/{prises}/power -m "1"'
                                subprocess.run(commande_allumer, shell=True)
                                pass

                            else:
                                # Allumer la prise
                                prise_data.update({'isOn': 'false'})

                                commande_allumer = f'mosquitto_pub -d -t cmnd/{prises}/power -m "0"'
                                subprocess.run(commande_allumer, shell=True)
                                pass

                            # Afficher la valeur de la prise
                            print("Valeur actuel (enfonction de la couleur et heure)de la prise:", valeur)

                            if prise_data != previous_data.get(user_id, {}).get(prise_id):

                                previous_prise_data = previous_data.get(user_id, {}).get(prise_id)
                                if previous_prise_data is not None:
                                    if prise_data.get('creuses_blanc') != previous_prise_data.get('creuses_blanc'):
                                        print("Changement de l'heure creuse/blanche")

                                    if prise_data.get('creuses_bleu') != previous_prise_data.get('creuses_bleu'):
                                        print("Changement de l'heure creuse/bleue")

                                    if prise_data.get('creuses_rouge') != previous_prise_data.get('creuses_rouge'):
                                        print("Changement de l'heure creuse/rouge")

                                    if prise_data.get('pleines_blanc') != previous_prise_data.get('pleines_blanc'):
                                        print("Changement de l'heure pleine/blanche")

                                    if prise_data.get('pleines_bleu') != previous_prise_data.get('pleines_bleu'):
                                        print("Changement de l'heure pleine/bleue")

                                    if prise_data.get('pleines_rouge') != previous_prise_data.get('pleines_rouge'):
                                        print("Changement de l'heure pleine/rouge")

                                # Mettre à jour les données précédentes
                                if user_id not in previous_data:
                                    previous_data[user_id] = {}
                                previous_data[user_id][prise_id] = prise_data
                            """
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
                            """
                    else:
                        print("Aucune prise pour cet utilisateur.")
                else:
                    print("Donnée utilisateur:", user_data)
    else:
        print("Aucun utilisateur trouvé.")

def main():
    previous_data = {}

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
        print(heure_creux_plein())
        time.sleep(2)

        ref = db.reference("/data")
        data = {
            "date": "{:04d}/{:02d}/{:02d}".format(now.tm_year, now.tm_mon, now.tm_mday),
            "dateJ1": (date.today() + timedelta(days=1)).strftime("%Y/%m/%d"),
            "couleurJ": color,
            "couleurJ1": colorJ1,
            "Jrest_bleu": Jrestants_BLEU,
            "Jrest_blanc": Jrestants_BLANC,
            "Jrest_rouge": Jrestants_ROUGE,
            "Pleines_creuses": heure_creux_plein()
        }
        ref.update(data)

        os.system("cls")

        # Dans la fonction main():
        ref = db.reference('/data/users')

        # Lire les données des utilisateurs
        users_data = ref.get()
        process_user_data(users_data, previous_data)
        if users_data is not None:
            ref.update(users_data)


async def send_notification(channel, error_message):
    # Remplacez 'channel' par le canal Discord spécifique où vous souhaitez envoyer les notifications

    # Créez le message
    message = f"Une erreur s'est produite : {error_message}"
    # Envoyez le message
    await channel.send(message)


async def main_loop():
    previous_data = {}

    while True:
        try:
            await main()

        except Exception as e:
            print(f"Une exception s'est produite : {e}")
            await send_notification(f"Une exception s'est produite : {e}")
            await asyncio.sleep(2)

# Définition de l'événement 'on_ready'
@client.event
async def on_ready():
    print(f'Logged in as {client.user}')
    client.loop.create_task(main_loop())

# Démarrage du bot
async def bot_start():
    print('Démarrage du bot...')
    await client.start('MTEyMDY2NzA0ODM0Mzc2OTEzOQ.GbjXZQ.8cCMq68KUpc-5EbDbE6GCyzOSWOH5-dbJmoObg')


# Execution principale
if __name__ == "__main__":
    crash_count = 0  # Compteur de crashes
    MAX_CRASH_COUNT = 2

    while crash_count < MAX_CRASH_COUNT:
        try:
            asyncio.run(bot_start())
        except Exception as e:
            print("Une exception s'est produite :", str(e))
            print("Redémarrage du code...")
            crash_count += 1
            time.sleep(2)
    else:
        print("Le code a crashé", MAX_CRASH_COUNT, "fois d'affilée. Arrêt du programme.")
        asyncio.run(send_notification(f"Le code a crashé {MAX_CRASH_COUNT} fois d'affilée. Arrêt du programme."))
        sys.exit()