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
    
    @EnvironmentObject var datas : ReadDatas
    
    @State var isPresented = false
    @Binding var prise: prise
    
    @State var reinitialiser : Bool = false
    
    @State var horaireperso : Bool = false
    @State var nomPrise : String = ""
    
    @State var creuses_bleu : Bool = false
    @State var pleines_bleu : Bool = false
    
    @State var creuses_blanc : Bool = false
    @State var pleines_blanc : Bool = false
    
    @State var creuses_rouge : Bool = false
    @State var pleines_rouge : Bool = false
    
    @State var isOn : Bool = false
    
    @State var isManualOn : Bool = false
    var body: some View {
        let priseRef = datas.nomPrise[prise.id.uuidString] != nil ?
        ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing: datas.nomPrise[prise.id.uuidString]!))") :
        ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing : prise.id))")
       
        
        ZStack {
            NavigationView {
                
                    
                ScrollView {
                    ZStack {
                        
                        VStack{
                            
                            Group{
                                
                                
                                
                                TextField("Nom de la prise", text: $prise.nom)
                                    
                                    .multilineTextAlignment(.center)
                                    .frame(width: 300)
                                    .textInputAutocapitalization(.none)
                                    .autocorrectionDisabled()
                                    .underlineTextField()
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                            Text("Votre prise est actuellement " + ((prise.isOn || prise.isManualOn != nil) ? "allumée" : "éteinte"))
                                .multilineTextAlignment(.center)
                            Spacer()
                            Text("Appuyez sur le bouton ci-dessous pour gérer l'alimentation manuelle")
                                .multilineTextAlignment(.center)
                            Button(action: {
                                withAnimation {
                                    isPresented = true
                                    
                                    
                                }
                            }){
                                Image(systemName: prise.isManualOn != nil ? "power.circle.fill" : "power.circle")
                                    .font(.system(size: 75))
                                    .frame(width: 70, height: 70)
                                    .foregroundColor(.darkBlue)
                            }
                            
                            
                            .onChange(of: prise.nom) { newValue in
                                nomPrise = newValue
                                priseRef.updateChildValues(["nom": nomPrise])
                                
                            }
                            
                            .onChange(of: prise.isOn) { newValue in
                                isOn = newValue
                                priseRef.updateChildValues(["isOn": isOn])
                                
                            }
                            
                            
                            Group{
                                Text("Jours bleus")
                                    .padding(.bottom)
                                    .font(.title)
                                Toggle("Activer la prise pendant les heures creuses", isOn: $prise.creuses_bleu)
                                    .font(.system(size : 17))
                                    .fontWeight(.semibold)
                                    .onChange(of: prise.creuses_bleu) { newValue in
                                        creuses_bleu = newValue
                                        priseRef.updateChildValues(["creuses_bleu": creuses_bleu])
                                        
                                    }
                                Toggle("Activer la prise pendant les heures pleines", isOn: $prise.pleines_bleu)
                                    .font(.system(size : 17))
                                    .fontWeight(.semibold)
                                    .onChange(of: prise.pleines_bleu) { newValue in
                                        pleines_bleu = newValue
                                        priseRef.updateChildValues(["pleines_bleu": pleines_bleu])
                                        
                                    }
                            }
                            
                            
                            Group{
                                Text("Jours blancs")
                                    .padding()
                                    .font(.title)
                                Toggle("Activer la prise pendant les heures creuses", isOn: $prise.creuses_blanc)
                                    .font(.system(size : 17))
                                    .fontWeight(.semibold)
                                    .onChange(of: prise.creuses_blanc) { newValue in
                                        creuses_blanc = newValue
                                        priseRef.updateChildValues(["creuses_blanc": creuses_blanc])
                                        
                                    }
                                Toggle("Activer la prise pendant les heures pleines", isOn: $prise.pleines_blanc)
                                    .font(.system(size : 17))
                                    .fontWeight(.semibold)
                                    .onChange(of: prise.pleines_blanc) { newValue in
                                        pleines_blanc = newValue
                                        priseRef.updateChildValues(["pleines_blanc": pleines_blanc])
                                        
                                    }
                            }
                            
                            
                            Group{
                                Text("Jours rouges")
                                    .padding()
                                    .font(.title)
                                Toggle("Activer la prise pendant les heures creuses", isOn: $prise.creuses_rouge)
                                    .font(.system(size : 17))
                                    .fontWeight(.semibold)
                                    .onChange(of: prise.creuses_rouge) { newValue in
                                        creuses_rouge = newValue
                                        priseRef.updateChildValues(["creuses_rouge": creuses_rouge])
                                        
                                    }
                                Toggle("Activer la prise pendant les heures pleines", isOn: $prise.pleines_rouge)
                                    .font(.system(size : 17))
                                    .fontWeight(.semibold)
                                    .onChange(of: prise.pleines_rouge) { newValue in
                                        pleines_rouge = newValue
                                        priseRef.updateChildValues(["pleines_rouge": pleines_rouge])
                                        
                                    }
                               
                            }
                            NavigationLink("Horaires personnalisées...", destination : HeuresPickerView(prise : $prise))
                                
                            
                            Button {
                                reinitialiser = true
                            } label: {
                                Text("Remettre les valeurs par défaut")
                                
                                    .font(.callout)
                                    .foregroundColor(.accentColor)
                                    
                                    
                            }
                            
                                .foregroundColor(.white)
                                .font(.footnote)
                                .actionSheet(isPresented: $reinitialiser) {
                                    ActionSheet(title: Text("Reinitialiser les valeurs de la prise et mettre les valeurs recommandées?"),
                                                buttons: [
                                                    
                                                    .destructive(Text("Réinitialiser"), action: {
                                                        prise.creuses_bleu = true
                                                        prise.pleines_bleu = true
                                                        
                                                        prise.creuses_blanc = true
                                                        prise.pleines_blanc = true
                                                        
                                                        prise.creuses_rouge = true
                                                        prise.pleines_rouge = false
                                                    }),
                                                    .cancel(Text("Annuler"), action: {
                                                        reinitialiser = false
                                                    })
                                                ])
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
                    .padding()
                    .navigationTitle("Informations")
                }
                
            }
            
            
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitleDisplayMode(.inline)
            IsManualOnView(isPresented: $isPresented, prise: $prise)
        }
        
        }
    }
    


struct InfoPriseView_Previews: PreviewProvider {
    static var previews: some View {
        InfoPriseView(prise: .constant(prise(nom: "", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false)))
            .environmentObject(ReadDatas())
            
    }
}
