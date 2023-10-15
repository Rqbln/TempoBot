import firebase_admin
from firebase_admin import credentials
from firebase_admin import db
import requests
import time

ip = "192.168.1.70"  # remplacer par l'adresse IP de votre prise Tasmota
command_on = "Power%20on"
command_off = "Power%20off"

# initialiser l'application Firebase
cred = credentials.Certificate('tempobot-406fc-firebase-adminsdk-o6bkq-a1ab9cdc76.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://tempobot-406fc-default-rtdb.europe-west1.firebasedatabase.app/'
})

# récupérer une référence à l'emplacement de la base de données
ref = db.reference('data/users/KP8dIxFtCBSshnxwRTSvHtskb5F2/prises/08F24CD6-DB99-4491-A5E4-DDD48B2283D6/isOn')

# récupérer les données
data = ref.get()

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

while True :
    time.sleep(1)
    ref = db.reference('data/users/KP8dIxFtCBSshnxwRTSvHtskb5F2/prises/08F24CD6-DB99-4491-A5E4-DDD48B2283D6/isOn')

    # récupérer les données
    data = ref.get()
    if data is True :
        set_power("ON")
    else :
        set_power("OFF")


# afficher les données
print(data)