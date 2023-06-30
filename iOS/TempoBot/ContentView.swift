//
//  ContentView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 08/02/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var datas : ReadDatas
    

    var body: some View {
        ZStack{
            if !datas.UserIsLoggedIn {
                Login().environmentObject(ReadDatas())
                
            }else{
                MainPage().environmentObject(ReadDatas())
            }
            NoConnectionAlertView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ReadDatas())
            .environmentObject(NetworkMonitor())
            
    }
}
