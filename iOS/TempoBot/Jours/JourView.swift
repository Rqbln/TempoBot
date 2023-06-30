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
            RoundedRectangle(cornerRadius: 15, style : .continuous)
                
                .frame(maxWidth: .infinity, maxHeight: 80)
                .foregroundColor(today.couleur)
                .overlay(
                    HStack{
                        VStack{
                            Text("\(today.date)")
                            Text("\(today.couleur_jour)")
                        }
                        .font(.callout)
                        
                        Spacer()
                        Text("\(jour)")
                            .font(.title2)
                        Spacer()
                        today.icone
                            .font(.system(size: 45))
                    }
                        .padding(.horizontal, 20)
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
