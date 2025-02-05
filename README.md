# TempoBot

Bienvenue dans **TempoBot**, un projet permettant de gérer intelligemment la consommation électrique de vos appareils en tirant parti du calendrier EDF Tempo.  
Ce dépôt contient à la fois :  
- Un bot/serveur Python (s’appuyant sur Tasmota, Firebase et Discord).  
- Une application iOS (SwiftUI) permettant de configurer et surveiller l’état de vos prises Tasmota.

---

## Sommaire
1. [Fonctionnalités principales](#fonctionnalités-principales)  
2. [Architecture du projet](#architecture-du-projet)  
3. [Installation et mise en route](#installation-et-mise-en-route)  
4. [Scripts Python importants](#scripts-python-importants)  
5. [Application iOS](#application-ios)  
6. [Configuration Firebase](#configuration-firebase)  
7. [Contribution et licence](#contribution-et-licence)

---

## Fonctionnalités principales

- **Suivi du calendrier EDF Tempo** : 
  - Détecte automatiquement la couleur du jour (bleu, blanc, rouge) et se met à jour à J+1.  
  - Nombre de jours restants pour chaque couleur dans l’année en cours.  

- **Allumage/Extinction automatique** :
  - Selon la couleur Tempo du jour (bleu, blanc ou rouge).
  - Possibilité de gérer les plages horaires pleines/creuses pour chacun des jours.

- **Horaires personnalisées** :
  - Planifie individuellement l’allumage de chaque prise (ex. du lundi 08h à 12h, etc.).  
  - Override manuel possible en un clic (depuis l’application iOS).  

- **Gestion Tasmota** :
  - Contrôle à distance de prises/matériel compatible Tasmota via MQTT.  
  - Configurable depuis un serveur Python et synchronisé avec Firebase.  

- **Application iOS** :
  - Interface complète pour ajouter de nouvelles prises (connexion Wi-Fi, configuration MQTT).  
  - Configuration de plages horaires personnalisées, statut en temps réel (allumé/éteint).  
  - Authentification Firebase (création de compte, login).

- **Port Forwarding** :
  - Fournit un script pour automatiser l’ouverture de ports UPnP (miniupnpc) si nécessaire.

---

## Architecture du projet

```
TempoBot
├── Python
│   ├── tasmota.py               # Script principal gérant la logique Tempo & Tasmota
│   ├── port_forwarding.py       # Script UPnP pour redirection de port
│   ├── test.py                  # Exemple d'automatisation (pyautogui)
│   ├── testdtata.py            # Exemple de lecture/écriture sur Firebase pour la prise
│   ├── ...
│   ├── tempobot-406fc-firebase-adminsdk-....json # Clé d'authentification Firebase
│   └── .deepsource.toml         # Configuration de l’analyse Python
│
└── iOS
    ├── TempoBot
    │   ├── *.swift              # Ensemble de fichiers SwiftUI (ContentView, MainPage, etc.)
    │   ├── Assets.xcassets      # Ressources (icônes, couleurs, images)
    │   ├── Info.plist           # Configuration du bundle
    │   ├── TempoBot.entitlements
    │   └── ... (fichiers Xcode)
    └── TempoBot.xcodeproj       # Projet Xcode
```

- **Python**  
  - Utilise `requests` pour récupérer la couleur Tempo du jour depuis l’API d’EDF.  
  - Contrôle les appareils Tasmota via MQTT et la base de données temps réel Firebase (trigger depuis `tasmota.py`).  
  - Publie également des notifications sur un salon Discord si vous le souhaitez (via `discord.py`).  

- **iOS (SwiftUI)**  
  - Application simple permettant :  
    1. L’authentification (Firebase Auth).  
    2. La création et configuration d’une prise (connexion Wi-Fi, paramétrage MQTT).  
    3. La modification du comportement (pleines/creuses, overrides manuels, etc.).  

---

## Installation et mise en route

### Côté Python
1. **Cloner le dépôt** :  
   ```bash
   git clone https://github.com/votre-user/TempoBot.git
   cd TempoBot/Python
   ```
2. **Installer les dépendances** :  
   - Python 3.x  
   - `pip install requests firebase_admin discord.py miniupnpc pyautogui ...` (selon vos besoins)  
3. **Configurer Firebase** :  
   - Placer votre fichier de service account JSON Firebase (`tempobot-406fc-firebase-adminsdk-o6bkq-...json`) dans le dossier `Python`.  
   - Vérifier que la clé `databaseURL` pointe bien vers votre instance Firebase.  
4. **Lancer le script principal** :  
   - `python tasmota.py`  
   - Le bot se connecte à Firebase, récupère la couleur Tempo, gère l’état de chaque prise et envoie éventuellement des messages sur Discord.

### Côté iOS
1. **Ouvrir le projet** dans Xcode (`TempoBot.xcodeproj`).  
2. **Configurer Firebase** :  
   - Ajouter le fichier `GoogleService-Info.plist` dans l’arborescence iOS (déjà inclus en exemple).  
   - Vérifier que l’ID du bundle correspond bien à celui configuré dans Firebase.  
3. **Lancer l’app** sur un simulateur ou un iPhone (iOS 16+).  
4. **Authentification** :  
   - Créez un compte ou connectez-vous avec un email/password Firebase.  
5. **Ajout d’une nouvelle prise** :  
   - Suivre les étapes dans l’app (détection du SSID `tasmota-*`, connexion au Wi-Fi de la prise, puis configuration du MQTT).  

---

## Scripts Python importants

- **`tasmota.py`**  
  - Script principal. Se connecte à la base de données Firebase, récupère la couleur Tempo via l’API EDF, et actionne/éteint automatiquement les prises Tasmota (via MQTT). Gère aussi l’override manuel et l’authentification sur Discord.

- **`port_forwarding.py`**  
  - Exemple d’utilisation de `miniupnpc` pour ajouter des règles de redirection de port (UPnP). Peut être utile si vous avez besoin d’accéder à votre machine/prise de l’extérieur.

- **`testdtata.py`**  
  - Exemple minimal pour lire/écrire dans la base de données Firebase, applicable à une seule prise.

- **`test.py`**  
  - Script un peu « gadget » illustrant la simulation de mouvements de souris avec `pyautogui`.

---

## Application iOS

- **SwiftUI** :  
  - **`ContentView.swift`** : Gère la logique globale (login ou affichage principal).  
  - **`MainPage.swift`** : Accueil post-authentification, affiche la couleur du jour et permet la navigation.  
  - **`PriseList.swift`** : Liste des prises configurées, options d’édition/suppression.  
  - **`ConnexionReseauView.swift / ConnexionReseau2View.swift`** : Séquence d’ajout d’une prise Tasmota (connexion Wi-Fi, IP, etc.).  
  - **`NouvellePriseView.swift`** : Configuration initiale (choix du nom, options pleines/creuses par couleur).  
  - **`HeuresPickerView.swift`** : Gérer les horaires personnalisées par jour de la semaine.  
  - **`IsManualOnView.swift`** : Vue d’override manuel (allumage/heure d’extinction).  

- **Authentification** :  
  - **`Login.swift` / `SignUp.swift`** : Création et connexion de comptes (via Firebase Auth).  
  - **`CompteView.swift`** : Informations du compte, possibilité de se déconnecter.  

- **Gestion du réseau** :  
  - **`NetworkMonitor`** : Détecte la perte de connexion internet pour afficher un message d’avertissement.  
  - **`NetworkDiscovery.swift`** : Exemple de découverte de services sur le LAN (NetServiceBrowser).  

---

## Configuration Firebase

1. **Projet Firebase** :  
   - Activer Firebase Authentication (Email/Password) et Realtime Database.  
2. **Clés** :  
   - Copiez les JSON nécessaires :  
     - Côté serveur Python (`tempobot-406fc-firebase-adminsdk-...json`).  
     - Côté iOS (`GoogleService-Info.plist`).  
3. **Arborescence de la base de données** (Realtime Database) :
   ```
   data
    ├── date
    ├── dateJ1
    ├── couleurJ
    ├── couleurJ1
    ├── Pleines_creuses
    ├── users
    │    └── <uid>
    │          └── prises
    │                └── <id_de_prise>
    │                      ├── nom
    │                      ├── isOn
    │                      ├── isManualOn
    │                      ├── creuses_bleu
    │                      ├── ...
   ```

---

## Contribution et licence

- **Contributions** : Les PR et suggestions sont les bienvenues !  

Pour toute question ou amélioration, n’hésitez pas à ouvrir une _issue_ ou à nous contacter.

---

**Merci d’utiliser TempoBot !**  
*Gérez efficacement votre consommation électrique grâce aux jours Tempo EDF et aux prises Tasmota.*
