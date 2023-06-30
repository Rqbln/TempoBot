//
//  ConnexionReseauView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 10/06/2023.
//

import SwiftUI
import NetworkExtension



struct ConnexionReseauView: View {
    @EnvironmentObject var datas : ReadDatas
    @State private var isPresented : Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    
                    
                    
                    Group{
                    Text("Etape 1 : Récupérer le nom de la prise")
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .padding(.top,50)
                    
                        Text("Pour récupérer le nom de la prise, allez dans vos paramètres et recopiez le nom de la prise dans le champ ci-dessous")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                            .multilineTextAlignment(.center)
                            .opacity(0.5)
                            .font(.headline)
                        
                        Text("  Exemple : \n tasmota-A1B2C3-1234")
                            .padding(.horizontal, 50)
                            .multilineTextAlignment(.center)
                            .opacity(0.5)
                            
                    }
                    
                    Button {
                        if let url = URL(string:"App-Prefs:root=WIFI") {
                            UIApplication.shared.open(url)
                        }
                    }
                    label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 30, style : .continuous)
                                .frame(width : 250, height: 50)
                                .foregroundColor(.orange)
                                
                            Text("Paramètres Wi-Fi")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    Spacer()
                    TextField("Nom de la prise", text: $datas.ssid)
                    
                        .font(.title)
                        .cornerRadius(20.0)
                        .frame(width: 300)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        
                        .multilineTextAlignment(.center)
                        .roundedTextField(texte: "Nom de la prise", colorScheme: colorScheme, color : .darkBlue)
                        .padding(.vertical)
                    Spacer()
                    NavigationLink {
                        ConnexionReseau2View()
                    } label: {
                        ZStack{
                            RoundedRectangle(cornerRadius: 30, style : .continuous)
                                .frame(maxWidth : .infinity, maxHeight: 65)
                                .foregroundColor(.darkBlue)
                                .shadow(color : .darkBlue, radius : 15, y: 10)
                            Text("Continuer")
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                        .frame(height: 150)
                        .padding(.horizontal)
                        
                    }

                    
                    Spacer()
                    Spacer()
                    
                    
                }
            }
           
        }
        .navigationTitle("Connexion à la prise")
        .navigationBarTitleDisplayMode(.inline)
        .navigationViewStyle(StackNavigationViewStyle())
        
    }

}


struct ConnexionReseauView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ConnexionReseauView()
                .environmentObject(ReadDatas())
        }
    }
}
