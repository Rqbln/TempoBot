//
//  ImageView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 20/06/2023.
//

import SwiftUI

struct ImageView: View {
    var body: some View {
        HStack {
            
            VStack {
                Image("eolienne")
                    .resizable()
                    .scaledToFill()
                .clipShape(Capsule())
                .ignoresSafeArea()
                .frame(width: 200, height: 600)
                Spacer()
            }
            
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView()
    }
}
