import requests

ip = "192.168.1.70"  # Remplacez cette adresse IP par celle de votre prise Tasmota
command_on = "Power%20on"
command_off = "Power%20off"

while True:
    command = input("Entrez la commande à envoyer (ON ou OFF) : ")
    if command.lower() == "on":
        url = f"http://{ip}/cm?cmnd={command_on}"
    elif command.lower() == "off":
        url = f"http://{ip}/cm?cmnd={command_off}"
    else:
        print("Commande invalide. Entrez ON ou OFF.")
        continue
    response = requests.get(url)
    print(response.text)






