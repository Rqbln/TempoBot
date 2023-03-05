//
//  HeurePickerView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 04/03/2023.
//
import SwiftUI
import Firebase
struct HeurePickerView : View {
    let ref = Database.database().reference()
    @State private var allumageDate = Date.now
    @State private var extinctionDate = Date.now
    @State private var isActive = false
    var jour : String
    var prise : prise

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        VStack{
            Toggle("Activer les horaires personnalisées pour " + jour.lowercased(), isOn: $isActive)
                .font(.system(size: 15))
            Group{
                Text(jour)
                    .font(.title2)
                
                HStack{
                    Text("La prise s'allume à")
                    Spacer()
                    DatePicker("", selection: $allumageDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "fr"))
                        .disabled(!isActive) // désactive si isActive est faux
                }
                
                
                HStack{
                    Text("Et s'éteint à")
                    Spacer()
                    DatePicker("", selection: $extinctionDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "fr"))
                        .disabled(!isActive) // désactive si isActive est faux
                }
                
                
                Text("Heure d'allumage : \(allumageDate, formatter: dateFormatter)")
                    .font(.footnote)
                Text("Heure d'extinction : \(extinctionDate, formatter: dateFormatter)")
                    .font(.footnote)
                Divider()
                    
            }
            .opacity(isActive ? 1.0 : 0.5) // réduit l'opacité si isActive est faux
        }
        .onAppear{
            if isActive{
                
            }
        }
        
    }
}

struct HeurePickerView_Previews: PreviewProvider {
    static var previews: some View {
        HeurePickerView(jour: "Lundi", prise: prise(nom: "test", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false))
    }
}
