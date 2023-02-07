import requests

url = "https://particulier.edf.fr/services/rest/referentiel/searchTempoStore?dateRelevant=2023-02-05"

reponse = str(requests.get(url).text)
dico = {"couleurJourJ":"TEMPO_BLEU","couleurJourJ1":"TEMPO_ROUGE"}
couleur = dico["couleurJourJ1"]
print(couleur)
if ("TEMPO_ROUGE"==couleur):
    print("cest rouge")

