import requests
import time

ip = "192.168.1.70"  # remplacer par l'adresse IP de votre prise Tasmota
command_on = "Power1"
command_off = "Power0"

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

def wait_for_red_day_end():
    while True:
        color = get_tempo_color()
        if color != "TEMPO_ROUGE":
            break
        time.sleep(60)

def main():
    while True:
        color = get_tempo_color()
        if color == "TEMPO_ROUGE":
            set_power("OFF")
            wait_for_red_day_end()
            set_power("ON")
        else:
            time.sleep(60)

if __name__ == "__main__":
    main()
