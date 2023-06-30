//
//  HeurePickerView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 04/03/2023.
//
import SwiftUI
import Firebase
struct HeurePickerView : View {
    @EnvironmentObject var datas : ReadDatas
    let ref = Database.database().reference()
    @State private var allumageDate = Date.now
    @State private var extinctionDate = Date.now
    @State private var isActive = false
    var jour : String
    var prise : prise
    private var priseRef: DatabaseReference {
        if datas.nomPrise[prise.id.uuidString] != nil {
            return ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing: datas.nomPrise[prise.id.uuidString]!))")
        } else {
            return ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing : prise.id))")
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    private func updateDatabase() {
        if isActive {
            priseRef.child(jour).setValue("\(dateFormatter.string(from: allumageDate))" + " - " + "\(dateFormatter.string(from: extinctionDate))")
        } else {
            priseRef.child(jour).removeValue()
        }
    }
    
    private func startListening() {
        priseRef.child(jour).observe(.value) { snapshot in
            if let value = snapshot.value as? String {
                isActive = true
                let times = value.split(separator: "-")
                if let allumage = dateFormatter.date(from: String(times[0]).trimmingCharacters(in: .whitespaces)),
                   let extinction = dateFormatter.date(from: String(times[1]).trimmingCharacters(in: .whitespaces)) {
                    allumageDate = allumage
                    extinctionDate = extinction
                }
            } else {
                isActive = false
            }
        }
    }


    var body: some View {

        VStack{
            Toggle("Activer les horaires personnalisées le " + jour.lowercased(), isOn: $isActive)
            
                .onChange(of: isActive) { _ in
                        updateDatabase()
                    }
            if isActive{
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
                
                Divider()
                    .onChange(of: allumageDate) { _ in
                        updateDatabase()
                    }
                    .onChange(of: extinctionDate) { _ in
                        updateDatabase()
                    }


            }
        }
        .padding()
        .onAppear {
            startListening()
        }
        
    }
}

struct HeurePickerView_Previews: PreviewProvider {
    static var previews: some View {
        HeurePickerView(jour: "Lundi", prise: prise(nom: "test", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false))
            .environmentObject(ReadDatas())
    }
}
