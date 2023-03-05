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
    
    @State var supprimer : Bool = false
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
                
                ScrollView{
                    VStack{
                        
                        
                        JourView(today: today, jour: "Aujourd'hui")
                        JourView(today: tomorrow, jour : "Demain")
                        
                        Spacer()
                        
                        Divider()
                            .padding()
                        
                        
                        ForEach($datas.prises) { $prise in
                            let priseRef = ref.child("data/prises").child("\(prise.id)")
                            RoundedRectangle(cornerRadius: 20)
                                .foregroundColor(prise.isOn ? .green : .secondary)
                                .frame(height: 100)
                                .overlay(
                                    HStack{
                                        Button {
                                            supprimer = true
                                        } label: {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .font(.system(size: 22))
                                        }
                                        .actionSheet(isPresented: $supprimer) {
                                            ActionSheet(title: Text("Supprimer la prise"),
                                                        message: Text("Êtes-vous sûr de vouloir supprimer cette prise ? Toutes ses données seront effacées."),
                                                        buttons: [
                                                            .destructive(Text("Supprimer"), action: {
                                                                priseRef.removeValue()
                                                                withAnimation{
                                                                    datas.prises.removeAll { $0.id == prise.id }
                                                                }
                                                                
                                                            }),
                                                            .cancel(Text("Annuler"), action: {
                                                                supprimer = false

                                                            })
                                                        ])
                                        }
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
                                .onAppear{
                                    let priseRef = ref.child("data/prises").child("\(prise.id)")
                                    priseRef.observe(.value) { snapshot in
                                        if let data = snapshot.value as? [String: Any] {
                                            prise.isOn = data["isOn"] as? Bool ?? false
                                            
                            
                                        }
                                    }
                                }
                        }
                                    
                        NavigationLink("Ajouter une nouvelle prise", destination: NouvellePriseView())
                            .foregroundColor(.accentColor)
                            
                        NavigationLink("QR code", destination:
                                        ZStack {
                                            ScannerView()
                                                .ignoresSafeArea()
                                            VStack {
                                                Text("Scanner QR code")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 30))
                                                Spacer()
                                            }
                        })
                            .padding()
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
            .environmentObject(ReadDatas())
            
    }
}
