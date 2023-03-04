//
//  NouvellePriseView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import SwiftUI
import Firebase


struct HeurePicker : View {
    let ref = Database.database().reference()
    @State private var allumageDate = Date.now
    @State private var extinctionDate = Date.now
    var jour : String

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        
        Text(jour)
            .font(.title2)
        
        HStack{
            Text("La prise s'allume à")
            Spacer()
            DatePicker("", selection: $allumageDate, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "fr"))
        }
        .padding(.horizontal)
        .padding(.horizontal)
        HStack{
            Text("Et s'éteint à")
            Spacer()
            DatePicker("", selection: $extinctionDate, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "fr"))
        }
        .padding(.horizontal)
        .padding(.horizontal)
        
        Text("Heure d'allumage : \(allumageDate, formatter: dateFormatter)")
            
            .font(.footnote)
        Text("Heure d'extinction : \(extinctionDate, formatter: dateFormatter)")
            
            .font(.footnote)
        Divider()
            .padding()
    }
}

struct NouvellePriseView: View {
    
    let ref = Database.database().reference()
    @Binding var prises : [prise]
    @State var horaireperso = false
    @State var nomPrise = ""
    
    @State var creuses_bleu : Bool = false
    @State var pleines_bleu : Bool = false
    
    @State var creuses_blanc : Bool = false
    @State var pleines_blanc : Bool = false
    
    @State var creuses_rouge : Bool = false
    @State var pleines_rouge : Bool = false
    
    var body: some View {
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
                
                Group{
                    Text("Horaires personnalisés")
                        .padding(.vertical)
                        .font(.title)
                    withAnimation(.linear){
                        Toggle("Activer les horaires personalisés", isOn : $horaireperso)
                    }
                    
                    
                    if horaireperso{
                        HeurePicker(jour: "Lundi")
                        HeurePicker(jour: "Mardi")
                        HeurePicker(jour: "Mercredi")
                        HeurePicker(jour: "Jeudi")
                        HeurePicker(jour: "Vendredi")
                        HeurePicker(jour: "Samedi")
                        HeurePicker(jour: "Dimanche")
                    }
                    
                }
                
                Button(action: {
                    
                    let nouvellePrise = prise(nom: nomPrise, creuses_bleu: creuses_bleu, pleines_bleu: pleines_bleu, creuses_blanc: creuses_blanc, pleines_blanc: pleines_blanc, creuses_rouge: creuses_rouge, pleines_rouge: pleines_rouge, isOn: false)
                    let priseRef = ref.child("data/prises").child("\(nouvellePrise.id.uuidString)")
                    prises.append(nouvellePrise)
                    nomPrise = ""
                        
                            priseRef.setValue(["nom": nouvellePrise.nom, "creuses_bleu": nouvellePrise.creuses_bleu, "pleines_bleu": nouvellePrise.pleines_bleu, "creuses_blanc": nouvellePrise.creuses_blanc, "pleines_blanc": nouvellePrise.pleines_blanc, "creuses_rouge": nouvellePrise.creuses_rouge, "pleines_rouge": nouvellePrise.pleines_rouge, "isOn": nouvellePrise.isOn])
                                
                            
                        
                    
                    
                }) {
                    Text("Ajouter la prise")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .disabled(nomPrise.isEmpty)
                Spacer()
            }
            .padding()
            
        }
    }
        
}
    struct NouvellePriseView_Previews: PreviewProvider {
        static var previews: some View {
            NouvellePriseView(prises: .constant([prise(nom: "test", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false)]))
        }
    }

