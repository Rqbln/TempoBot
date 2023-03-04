//
//  MainPage.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 09/02/2023.
//

import SwiftUI
import Firebase


struct MainPage: View {

    @ObservedObject var datas = ReadDatas()
    @State var prises: [prise] = []
    @State var today: jour = jour(couleur: .blue, date: "pas défini", couleur_jour: "pas défini")
    @State var tomorrow: jour = jour(couleur: .red, date: "pas défini", couleur_jour: "pas défini")

    let ref = Database.database().reference()
    
    func determiner_couleur(_ CouleurJ : String) -> Color{
        switch CouleurJ{
        case "TEMPO_BLEU" :
            return Color.teal
        
        case "TEMPO_BLANC" :
            return Color.gray
        
        case "TEMPO_ROUGE" :
            return Color.red
        
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
            
        default :
            return "erreur"
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack {
                LinearGradient(colors: [ Color("Violet foncé"), Color("Bleu foncé")], startPoint: .leading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                ScrollView{
                    VStack{
                        
                        
                        JourView(today: today, jour: "Aujourd'hui")
                        JourView(today: tomorrow, jour : "Demain")
                        
                        Spacer()
                        
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(height: 0.2)
                            .opacity(0.5)
                            .padding()
                        
                        
                        ForEach($prises) { $prise in
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(prise.isOn ? .green : .secondary)
                                .frame(height: 100)
                                .opacity(prise.isOn ? 0.5 : 1)
                                .overlay(
                                    HStack{
                                        Spacer()
                                        Text(prise.nom)
                                        Spacer()
                                        NavigationLink(destination: InfoPriseView(prise: $prise)) {
                                            Image(systemName: "line.horizontal.3")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .padding()
                                    .font(.system(size: 25))
                                )
                                .foregroundColor(.white)
                                .padding(.horizontal)
                        }
                                    
                        NavigationLink("Ajouter une nouvelle prise", destination: NouvellePriseView(prises: $prises))
                            .foregroundColor(.accentColor)
                            .padding(.top)
                        
                    }
                }
            }
            .navigationTitle("Accueil")
        }
        
        // Déclenche les fonctions qui observent des changements sur la base de donnée lorsque la vue s'affiche
        .onAppear {
            datas.startObservingCouleurJ()
            datas.startObservingCouleurJ1()
            datas.startObservingDate()
            datas.startObservingDateJ1()
        }
        
        // Regarde les changements sur la variable couleurJ
        .onChange(of: datas.couleurJ) { newValue in
            if let couleurJ = newValue {
                today.couleur_jour = "Jour " + determiner_couleur_texte(couleurJ)
                today.couleur = determiner_couleur(couleurJ)
            }
        }
        // Regarde les changements sur la variable couleurJ1
        .onChange(of: datas.couleurJ1) { newValue in
            if let couleurJ1 = newValue {
                tomorrow.couleur_jour = "Jour " + determiner_couleur_texte(couleurJ1)
                tomorrow.couleur = determiner_couleur(couleurJ1)
            }
        }
        // Regarde les changements sur la variable date
        .onChange(of: datas.date) { newValue in
            if let date = newValue {
                today.date = date
            }
        }
        // Regarde les changements sur la variable dateJ1
        .onChange(of: datas.dateJ1){ newValue in
            if let dateJ1 = newValue {
                tomorrow.date = dateJ1
            }
        }
    }
}

struct MainPage_Previews: PreviewProvider {
    static var previews: some View {
        MainPage()
            
    }
}
