//
//  NoConnectionAlertView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 24/06/2023.
//

import SwiftUI

struct NoConnectionAlertView: View {
    @EnvironmentObject var networkChecker : NetworkMonitor
    
    @EnvironmentObject var datas : ReadDatas
    @Environment(\.colorScheme) var colorScheme
    @State var opacity = 0.0
    var body: some View {
        VStack {
            if !networkChecker.isConnected && !(datas.getWiFiSsid()?.starts(with: "tasmota-") ?? true){
                if colorScheme == .dark{
                    Color.black
                    .opacity(opacity)
                    .overlay(
                        
                        VStack {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 120))
                            Text("Vous êtes hors connexion")
                                .font(.system(size: 36))
                                .padding()
                                .fontWeight(.light)
                            Text("Rétablissez votre connexion et réessayez")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                            
                            
                        }
                            .opacity(opacity)
                            
                    )
                }else{
                    Color.white
                    .opacity(opacity)
                    .overlay(
                        
                        VStack {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 120))
                            Text("Vous êtes hors connexion")
                                .font(.system(size: 36))
                                .padding()
                                .fontWeight(.light)
                            Text("Rétablissez votre connexion et réessayez")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                            
                            
                        }
                            .opacity(opacity)
                            
                    )
                }
                    
                
            }
        }
        .ignoresSafeArea()
        .onAppear(){
            withAnimation{
                opacity = 1.0
            }
        }
    }
}


struct NoConnectionAlertView_Previews: PreviewProvider {
    static var previews: some View {
        NoConnectionAlertView()
            .environmentObject(NetworkMonitor())
            .environmentObject(ReadDatas())
    }
}
