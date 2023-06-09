import miniupnpc#sudo apt-get install libminiupnpc-dev

import requests

ip_address = requests.get('https://api.ipify.org').text
print(f"L'adresse IP publique est : {ip_address}")

# Adresse IP de l'appareil à rediriger le port
ip = '172.20.10.2'

# Créez une instance de l'objet UPnP
u = miniupnpc.UPnP()

# Découvrez le routeur
u.discoverdelay = 200
u.discover()

# Obtenez les informations de la passerelle et imprimez-les
gateway = u.selectigd()
print('Gateway:', gateway)

# Ajoutez une redirection de port
external_port = 8000  # port externe
internal_port = 80  # port interne
protocol = 'TCP'
description = 'Ma redirection de port'

u.addportmapping(external_port, protocol, ip, internal_port, description, '')
print('Port forwarding activé avec succès.')


# comment ca marche: code au dessus a ex sur machine client / depuis chez nous acces en entrant ip publique du client plus le port

#on va surement devoir l'integrer dans l'app voici le code en swift :
'''
import Foundation
import MiniUPnP

// Récupère l'adresse IP publique
func getPublicIPAddress(completion: @escaping (String?) -> Void) {
    let url = URL(string: "https://api.ipify.org")!
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        let ip = String(data: data, encoding: .utf8)
        completion(ip)
    }
    task.resume()
}

// Ajoute une redirection de port UPnP
func addPortMapping(externalPort: UInt16, internalPort: UInt16, protocol: String, description: String, completion: @escaping (Bool) -> Void) {
    let upnp = UPNP()
    let gateway = upnp.selectInternetGatewayDevice()
    guard gateway != nil else {
        completion(false)
        return
    }
    let result = gateway!.addPortMapping(withRemoteHost: nil, externalPort: externalPort, internalHost: "192.168.65.100", internalPort: internalPort, protocol: protocol, description: description, leaseDuration: 0)
    completion(result)
}

// Utilisation des fonctions
getPublicIPAddress { (ip) in
    if let ip = ip {
        print("L'adresse IP publique est : \(ip)")
    }
}

addPortMapping(externalPort: 8000, internalPort: 80, protocol: "TCP", description: "Ma redirection de port") { (result) in
    if result {
        print("Port forwarding activé avec succès.")
    }
}
'''