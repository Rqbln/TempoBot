import pyrebase

config = {
  "apiKey": "a1ab9cdc76097a51e7f2975107179f65365cf489",
  "authDomain": "tempobot-7eea7.firebaseapp.com",
  "databaseURL": "https://tempobot-406fc-default-rtdb.europe-west1.firebasedatabase.app/",
  "storageBucket": "gs://tempobot-7eea7.appspot.com"
}

firebase = pyrebase.initialize_app(config)
db = firebase.database()

# Récupérer toutes les données de la base de données
data = db.get()

# Récupérer les données d'un nœud spécifique de l'arbre
node_data = db.child("data").get()

