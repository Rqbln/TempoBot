//
//  CompteView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 06/03/2023.
//

import SwiftUI
import Firebase
struct CompteView: View {
    
    @EnvironmentObject var datas: ReadDatas
    @State var deco = false
    @State private var showingActionSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if Auth.auth().currentUser?.email != nil { // Affiche le contenu seulement si l'utilisateur est connecté
                    ZStack {
                        Color(UIColor.systemGroupedBackground)
                            .ignoresSafeArea(.all)
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 100))
                                .foregroundColor(.accentColor)
                            
                            List {
                                Text("Email: \(Auth.auth().currentUser?.email ?? "Erreur")")
                                    .font(.system(size: 20))
                                
                                Button(action: {
                                            showingActionSheet = true
                                        }) {
                                            Text("Se déconnecter")
                                                .foregroundColor(.red)
                                                .font(.system(size: 20))
                                        }
                            }
                            .actionSheet(isPresented: $showingActionSheet) {
                                       ActionSheet(title: Text("Êtes-vous sûr de vouloir vous déconnecter ?"), buttons: [
                                           .destructive(Text("Déconnexion"), action: {
                                               do {
                                                   try Auth.auth().signOut()
                                                   datas.uid = nil
                                                   datas.save_uid()
                                                   datas.prises = []
                                                   withAnimation{
                                                       datas.UserIsLoggedIn = false
                                                   }
                                                   
                                               } catch {
                                                   print("Erreur de déconnexion")
                                               }
                                           }),
                                           .cancel()
                                       ])
                                   }
                            .listStyle(.grouped)
                            
                        }
                        .navigationTitle("Mon compte")
                    }
                }
                    
            }
            .navigationDestination(isPresented: .constant(!datas.UserIsLoggedIn)) {
                Login()
            }

        }
    }
}


struct CompteView_Previews: PreviewProvider {
    static var previews: some View {
        CompteView()
            .environmentObject(ReadDatas())
    }
}


