//
//  TempoBotApp.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 08/02/2023.
//

import SwiftUI
import Firebase

@main
struct TempoBotApp: App {
    @StateObject var datas = ReadDatas()
    @StateObject var networkChecker = NetworkMonitor()
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(datas)
                .environmentObject(networkChecker)
                .environment(\.locale, Locale(identifier: "fr"))
        }
    }
}
