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
    
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.locale, Locale(identifier: "fr"))
        }
    }
}
