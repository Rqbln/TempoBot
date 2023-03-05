//
//  ParametresAvancésView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 05/03/2023.
//

import SwiftUI
import Firebase

struct ParametresAvancesView: View {
    let ref = Database.database().reference()
    @EnvironmentObject var datas : ReadDatas
    @Binding var prise : prise
    
    
    @State var reinitialiser : Bool = false
    var body: some View {
        let priseRef = ref.child("data/prises").child("\(prise.id.uuidString)")
        NavigationStack {
            List {
                NavigationLink(destination:
                                Group{
                    ScrollView{
                        HeurePickerView(jour: "Lundi", prise : prise)
                        HeurePickerView(jour: "Mardi", prise : prise)
                        HeurePickerView(jour: "Mercredi", prise : prise)
                        HeurePickerView(jour: "Jeudi", prise : prise)
                        HeurePickerView(jour: "Vendredi", prise : prise)
                        HeurePickerView(jour: "Samedi", prise : prise)
                        HeurePickerView(jour: "Dimanche", prise : prise)
                            .navigationTitle("Horaires personnalisées")
                    }
                }
                ) {
                    Text("Horaires personnalisées...")
                    
                        .foregroundColor(.accentColor)
                        .font(.system(size: 22))
                }
                
                Button {
                    reinitialiser = true
                } label: {
                    Text("Remettre les valeurs par défaut")
                    
                        .foregroundColor(.accentColor)
                        .font(.system(size: 22))
                }
                
                .actionSheet(isPresented: $reinitialiser) {
                    ActionSheet(title: Text("Remettre les valeurs par défaut"),
                                message: Text("Êtes-vous sûr de vouloir réinitialiser les valeurs par défaut ? Toutes les valeurs personnalisées seront perdues."),
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
                
                
                .navigationTitle("Paramètres avancés")
            }
            .onChange(of: prise.creuses_bleu) { newValue in
                priseRef.updateChildValues(["creuses_bleu": prise.creuses_bleu])
            }
            .onChange(of: prise.pleines_bleu) { newValue in
                priseRef.updateChildValues(["pleines_bleu": prise.pleines_bleu])
            }
            
            .onChange(of: prise.creuses_blanc) { newValue in
                priseRef.updateChildValues(["creuses_blanc": prise.creuses_blanc])
            }
            .onChange(of: prise.pleines_blanc) { newValue in
                priseRef.updateChildValues(["pleines_blanc": prise.pleines_blanc])
            }
            
            .onChange(of: prise.creuses_rouge) { newValue in
                priseRef.updateChildValues(["creuses_rouge": prise.creuses_rouge])
            }
            .onChange(of: prise.pleines_rouge) { newValue in
                priseRef.updateChildValues(["pleines_rouge": prise.pleines_rouge])
            }
            
            .listStyle(.insetGrouped)
            
            
            
            
            
        }
    }
}

struct ParametresAvancesView_Previews: PreviewProvider {
    static var previews: some View {
        ParametresAvancesView(prise: .constant(prise(nom: "test", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false)))
            .environmentObject(ReadDatas())
    }
}
