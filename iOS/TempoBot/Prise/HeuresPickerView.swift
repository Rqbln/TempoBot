//
//  HeuresPickerView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 06/03/2023.
//

import SwiftUI

struct HeuresPickerView: View {
    @Binding var prise : prise
    var body: some View {
        ScrollView{
            Group{
                HeurePickerView(jour: "Lundi", prise : prise)
                HeurePickerView(jour: "Mardi", prise : prise)
                HeurePickerView(jour: "Mercredi", prise : prise)
                HeurePickerView(jour: "Jeudi", prise : prise)
                HeurePickerView(jour: "Vendredi", prise : prise)
                HeurePickerView(jour: "Samedi", prise : prise)
                HeurePickerView(jour: "Dimanche", prise : prise)
            }
                .navigationTitle("Horaires personnalisées")
                .navigationBarTitleDisplayMode(.inline)
        
        }
        
    }
}

struct HeuresPickerView_Previews: PreviewProvider {
    static var previews: some View {
            HeuresPickerView(prise: .constant(prise(nom: "test", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false)))
        
    }
}
