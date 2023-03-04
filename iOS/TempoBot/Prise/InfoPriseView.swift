//
//  InfoPriseView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import SwiftUI
import Firebase

struct InfoPriseView: View {
    let ref = Database.database().reference()
    @Binding var prise: prise
    
    @State var horaireperso : Bool = false
    @State var nomPrise : String = ""
    
    @State var creuses_bleu : Bool = false
    @State var pleines_bleu : Bool = false
    
    @State var creuses_blanc : Bool = false
    @State var pleines_blanc : Bool = false
    
    @State var creuses_rouge : Bool = false
    @State var pleines_rouge : Bool = false
    
    @State var isOn : Bool = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [ Color("Violet foncé"), Color("Bleu foncé")], startPoint: .leading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            VStack{
                
                Group{
                    Text("Informations sur la prise")
                        .font(.title)
                    
                    TextField("Nom de la prise", text: $prise.nom)
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                        .padding()
                        .background(.white)
                        .cornerRadius(10.0)
                        .autocorrectionDisabled()
                        .foregroundColor(.black)
                        .onChange(of: prise.nom) { newValue in
                                nomPrise = newValue
                            }
                    
                    Text("Votre prise est actuellement " + (prise.isOn ? "allumée biiite" : "éteinte"))
                    Spacer()
                    Text("Appuyez sur le bouton ci-dessous pour gérer l'alimentation")
                        .multilineTextAlignment(.center)
                    Button(action: {
                        withAnimation {
                            prise.isOn.toggle()
                                
                        }
                    }){
                        Image(systemName: prise.isOn ? "power.circle.fill" : "power.circle")
                            .font(.system(size: 75))
                            .frame(width: 70, height: 70)
                            .foregroundColor(prise.isOn ? .green : .primary)
                    }
                    .onChange(of: prise.isOn) { newValue in
                        isOn = newValue
                    }
                }
                .foregroundColor(.white)
                
                Group{
                    Text("Jours bleus")
                        .padding(.bottom)
                        .font(.title)
                    Toggle("Activer la prise pendant les heures creuses", isOn: $prise.creuses_bleu)
                        .onChange(of: prise.creuses_bleu) { newValue in
                                creuses_bleu = newValue
                            }
                    Toggle("Activer la prise pendant les heures pleines", isOn: $prise.pleines_bleu)
                        .onChange(of: prise.pleines_bleu) { newValue in
                                pleines_bleu = newValue
                            }
                }
                .foregroundColor(.white)
                
                Group{
                    Text("Jours blancs")
                        .padding()
                        .font(.title)
                    Toggle("Activer la prise pendant les heures creuses", isOn: $prise.creuses_blanc)
                        .onChange(of: prise.creuses_blanc) { newValue in
                                creuses_blanc = newValue
                            }
                    Toggle("Activer la prise pendant les heures pleines", isOn: $prise.pleines_blanc)
                        .onChange(of: prise.pleines_blanc) { newValue in
                                pleines_blanc = newValue
                            }
                }
                .foregroundColor(.white)
                
                Group{
                    Text("Jours rouges")
                        .padding()
                        .font(.title)
                    Toggle("Activer la prise pendant les heures creuses", isOn: $prise.creuses_rouge)
                        .onChange(of: prise.creuses_rouge) { newValue in
                                creuses_rouge = newValue
                            }
                    Toggle("Activer la prise pendant les heures pleines", isOn: $prise.pleines_rouge)
                        .onChange(of: prise.pleines_rouge) { newValue in
                                pleines_rouge = newValue
                            }
                }
                .foregroundColor(.white)
                
                Spacer()
                    .foregroundColor(.white)
                    .font(.footnote)
                
                Button(action: {
                    let priseRef = ref.child("data/prises").child("\(prise.id.uuidString)")
                    priseRef.updateChildValues(["nom": nomPrise, "creuses_bleu": creuses_bleu, "pleines_bleu": pleines_bleu, "creuses_blanc": creuses_blanc, "pleines_blanc": pleines_blanc, "creuses_rouge": creuses_rouge, "pleines_rouge": pleines_rouge, "isOn": isOn])
                }) {
                    Text("Sauvegarder les changements")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .padding(.top)
                .disabled(nomPrise.isEmpty)
                Spacer()
                
            }
            .padding()
            .onAppear{
                let priseRef = ref.child("data/prises").child("\(prise.id)")
                priseRef.observe(.value) { snapshot in
                    if let data = snapshot.value as? [String: Any] {
                        prise.nom = data["nom"] as? String ?? ""
                        prise.creuses_bleu = data["creuses_bleu"] as? Bool ?? false
                        prise.pleines_bleu = data["pleines_bleu"] as? Bool ?? false
                        prise.creuses_blanc = data["creuses_blanc"] as? Bool ?? false
                        prise.pleines_blanc = data["pleines_blanc"] as? Bool ?? false
                        prise.creuses_rouge = data["creuses_rouge"] as? Bool ?? false
                        prise.pleines_rouge = data["pleines_rouge"] as? Bool ?? false
                        prise.isOn = data["isOn"] as? Bool ?? false
                        
                        // Mise à jour des valeurs des états dans la vue
                        nomPrise = prise.nom
                        creuses_bleu = prise.creuses_bleu
                        pleines_bleu = prise.pleines_bleu
                        creuses_blanc = prise.creuses_blanc
                        pleines_blanc = prise.pleines_blanc
                        creuses_rouge = prise.creuses_rouge
                        pleines_rouge = prise.pleines_rouge
                        isOn = prise.isOn
                    }
                }
            }
            }     
        }
    }


struct InfoPriseView_Previews: PreviewProvider {
    static var previews: some View {
        InfoPriseView(prise: .constant(prise(nom: "", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false)))
    }
}
