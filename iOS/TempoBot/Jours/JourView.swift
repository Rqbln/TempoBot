//
//  JourView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 10/02/2023.
//

import SwiftUI

struct JourView: View {
    var today : jour
    var jour : String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style : .continuous)
                .frame(width: 400, height: 100)
                .foregroundColor(today.couleur)
                .overlay(
                    HStack{
                        VStack{
                            Text("\(today.date)")
                            Text("\(today.couleur_jour)")
                        }
                        
                        Spacer()
                        Text("\(jour)")
                            .font(.title)
                        Spacer()
                        today.icone
                            .font(.system(size: 60))
                    }
                        .padding()
                        .foregroundColor(.white)
                )
        }
    }
}


struct JourView_Previews: PreviewProvider {
    static var previews: some View {
        JourView(today: jour(couleur: Color(.green), date: "2023/03/03", couleur_jour: "Erreur"), jour: "Aujourd'hui")
    }
}
