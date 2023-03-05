//
//  NouvellePriseView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import SwiftUI
import Firebase




struct NouvellePriseView: View {
    
    
    let ref = Database.database().reference()

    @EnvironmentObject var datas : ReadDatas
    
    @State var horaireperso = false
    @State var nomPrise = ""
    
    @State var creuses_bleu : Bool = true
    @State var pleines_bleu : Bool = true
    
    @State var creuses_blanc : Bool = true
    @State var pleines_blanc : Bool = true
    
    @State var creuses_rouge : Bool = true
    @State var pleines_rouge : Bool = false
    

    
    var body: some View {
        var nouvellePrise = prise(nom: nomPrise, creuses_bleu: creuses_bleu, pleines_bleu: pleines_bleu, creuses_blanc: creuses_blanc, pleines_blanc: pleines_blanc, creuses_rouge: creuses_rouge, pleines_rouge: pleines_rouge, isOn: false)
        NavigationStack {
            ScrollView{
                VStack{
                    
                    TextField("Nom de la prise", text: $nomPrise)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(.quaternary)
                        .cornerRadius(10)
                        .frame(width: 400)
                        .multilineTextAlignment(.center)
                    Group{
                        Text("Jours bleus")
                            .padding(.bottom)
                            .font(.title)
                        Toggle("Activer la prise pendant les heures creuses", isOn: $creuses_bleu)
                        Toggle("Activer la prise pendant les heures pleines", isOn: $pleines_bleu)
                    }
                    
                    
                    
                    Group{
                        Text("Jours blancs")
                            .padding(.vertical)
                            .font(.title)
                        Toggle("Activer la prise pendant les heures creuses", isOn: $creuses_blanc)
                        Toggle("Activer la prise pendant les heures pleines", isOn: $pleines_blanc)
                    }
                    
                    
                    Group{
                        Text("Jours rouges")
                            .padding(.vertical)
                            .font(.title)
                        Toggle("Activer la prise pendant les heures creuses", isOn: $creuses_rouge)
                        Toggle("Activer la prise pendant les heures pleines", isOn: $pleines_rouge)
                    }
                }
                    
                    Button(action: {
                        
                        nouvellePrise = prise(nom: nomPrise, creuses_bleu: creuses_bleu, pleines_bleu: pleines_bleu, creuses_blanc: creuses_blanc, pleines_blanc: pleines_blanc, creuses_rouge: creuses_rouge, pleines_rouge: pleines_rouge, isOn: false)
                        let priseRef = ref.child("data/prises").child("\(nouvellePrise.id.uuidString)")
                        datas.prises.append(nouvellePrise)
                        nomPrise = ""
                            
                                priseRef.setValue(["nom": nouvellePrise.nom, "creuses_bleu": nouvellePrise.creuses_bleu, "pleines_bleu": nouvellePrise.pleines_bleu, "creuses_blanc": nouvellePrise.creuses_blanc, "pleines_blanc": nouvellePrise.pleines_blanc, "creuses_rouge": nouvellePrise.creuses_rouge, "pleines_rouge": nouvellePrise.pleines_rouge, "isOn": nouvellePrise.isOn])
                                    
                                
                            
                        
                        
                    }) {
                        Text("Ajouter la prise")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                    .padding()
                    .disabled(nomPrise.isEmpty)
                    Spacer()
                }
                
                    
            .padding()
        }
            
        }
    }
        

    struct NouvellePriseView_Previews: PreviewProvider {
        static var previews: some View {
            NouvellePriseView()
                .environmentObject(ReadDatas())
        }
    }

