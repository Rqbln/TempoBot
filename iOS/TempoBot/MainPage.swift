//
//  MainPage.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 09/02/2023.
//

import SwiftUI
import Firebase



struct MainPage: View {

    @EnvironmentObject var datas : ReadDatas
    
    @State var supprimer: Int?
    @State var today: jour = jour(couleur: .blue, date: "pas défini", couleur_jour: "pas défini")
    @State var tomorrow: jour = jour(couleur: .red, date: "pas défini", couleur_jour: "pas défini")
    @State var HasLoadedDatas = false
    
    let ref = Database.database().reference()
    

    func determiner_couleur(_ CouleurJ : String) -> Color{
        switch CouleurJ{
        case "TEMPO_BLEU" :
            return Color.teal
        
        case "TEMPO_BLANC" :
            return Color(.lightGray)
        
        case "TEMPO_ROUGE" :
            return Color.red
        
        case "NON_DEFINI" :
            return Color.orange
        default :
            return Color.green
        }
    }
    
    func determiner_couleur_texte(_ CouleurJ : String) -> String{
        switch CouleurJ{
        case "TEMPO_BLEU" :
            return "bleu"
            
        case "TEMPO_BLANC" :
            return "blanc"
        
        case "TEMPO_ROUGE" :
            return "rouge"
        
        case "NON_DEFINI" :
            return "non défini"
        default :
            return "erreur"
        }
    }
    
    var body: some View {
        
        
            NavigationStack{
       
                ScrollView {
                    ZStack {
                            
                            VStack {
                                JourView(today: today, jour: "Aujourd'hui")
                                    .frame(height : 80)
                                    .padding(.horizontal, 5)
                                JourView(today: tomorrow, jour : "Demain")
                                    .padding(.horizontal, 5)
                                    .frame(height : 80)
                                
                                    VStack{
                                        Rectangle()
                                            .frame(maxWidth: .infinity, maxHeight : 0.3)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal)
                                            .padding(.top)
                                            
                                        NavigationLink {
                                            ConnexionReseauView()
                                        } label: {
                                            ZStack {
                                                Text("Ajouter une nouvelle prise")
                                                    .fontWeight(.bold)
                                                    .font(.system(size : 22))
                                                    .padding()
                                                    
                                                    .foregroundColor(.white)
                                                    .zIndex(10)
                                                RoundedRectangle(cornerRadius: 20, style : .continuous)
                                                    
                                                    .frame(maxWidth : .infinity, maxHeight : 65)
                                                    
                                                    .padding(.horizontal, 50)
                                                    .foregroundColor(.darkBlue)
                                            }
                                            .padding(.vertical)
                                                
                                        }
                                        PriseList(supprimer: $supprimer)
                                }
                            }
                        }
                        
                        .navigationBarItems(
                                        trailing:
                                            NavigationLink(destination: CompteView()) {
                                                Image(systemName: "person.circle.fill")
                                                    .foregroundColor(.accentColor)
                                                    .font(.system(size: 24))
                                            }
                                    )
                    .navigationTitle("Accueil")
                }
               
            }
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            
            .onAppear {
                if !datas.HasLoadedDatas{
                    datas.recuperer_prises()
                    datas.HasLoadedDatas = true
                }
                
                let dataRef = ref.child("data")
                dataRef.observeSingleEvent(of: .value) { snapshot, _  in
                    guard let data = snapshot.value as? [String: Any],
                            let couleurJ = data["couleurJ"] as? String,
                            let couleurJ1 = data["couleurJ1"] as? String,
                            let date = data["date"] as? String,
                            let dateJ1 = data["dateJ1"] as? String
                    else { return }
                                
                            
                    today.couleur_jour = "Jour " + determiner_couleur_texte(couleurJ)
                    today.couleur = determiner_couleur(couleurJ)
                    tomorrow.couleur_jour = "Jour " + determiner_couleur_texte(couleurJ1)
                    tomorrow.couleur = determiner_couleur(couleurJ1)
                    today.date = date
                    tomorrow.date = dateJ1
                            }
                
                        }

    }
        
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
            .environmentObject(ReadDatas())
            
    }
}
