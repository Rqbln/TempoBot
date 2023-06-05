import subprocess

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


if __name__ == "__main__":
    set_power()