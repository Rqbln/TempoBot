//
//  ConnexionReseau2View.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 11/06/2023.
//

import SwiftUI
import NetworkExtension
struct ConnexionReseau2View: View {
    @EnvironmentObject var datas : ReadDatas
    @State var connection_state = ""
    @State var deviceIsOnline = false
    @State var isPresented : Bool = false
    @State var nouvelle_ip = ""
    @ObservedObject private var networkServiceDiscovery = NetworkServiceDiscovery()
    @State private var tasmotaDevices: [String] = []
    
    @State var isQuitting = false
    @State private var showingAlert = false
    @Environment(\.colorScheme) var colorScheme
    func checkDeviceStatus(ipAddress: String) {
            guard let url = URL(string: "http://\(ipAddress)/cm?cmnd=Status") else {
                print("Invalid URL")
                return
            }
            
            

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("HTTP Request Failed: \(error.localizedDescription)")
                    connection_state = "La connexion a échoué. Assurez-vous d'avoir bien connecté l'appareil à internet et d'avoir rentré la bonne adresse IP"
                }

                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        self.deviceIsOnline = httpResponse.statusCode == 200
                        if deviceIsOnline {
                            
                            connection_state = "Connected"
                            isPresented = true
                        }
                    }
                }
            }

            task.resume()
        }

    
    func connectToWifi(ssid: String) {
            let hotspotConfig = NEHotspotConfiguration(ssid: ssid)
            hotspotConfig.joinOnce = true

            NEHotspotConfigurationManager.shared.apply(hotspotConfig) { (error) in
                if let error = error {
                    print("Erreur : \(error)")
                    }
            }
        }
    
    
    

        
    var body: some View {
        NavigationView{
            ScrollView {
                VStack{
                    Text("Etape 2 : Connecter la prise à internet")
                        .font(.system(size: 24))
                        .bold()
                        .multilineTextAlignment(.leading)
                        .padding(.top,50)
                    
                    Text("Si la prise n\'émet pas de lumière bleue / violette, appuyez sur son bouton pendant 5 secondes")
                        .font(.system(size: 16))
                        .bold()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("Pour connecter la prise à internet :")
                        
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                        .opacity(0.5)
                        .font(.system(size: 15))
                    
                
                        Text("\n 1. cliquez sur le bouton ci-dessous \n 2. cliquez sur \"Rejoindre” \n 3. sur la page qui s'ouvre, cliquez sur votre réseau Wi-Fi et rentrez votre mot de passe \n 4. ne touchez à rien et attendez que la page se ferme (quelques secondes)")
                            .padding(.horizontal)
                            .foregroundColor(.secondary)
                            .font(.system(size: 15))

                    
                    Button {
                        connectToWifi(ssid: datas.ssid)
                    }
                    label:{
                        HStack {
                            ZStack{
                                RoundedRectangle(cornerRadius: 30, style : .continuous)
                                    .frame(width : 250, height: 65)
                                    .foregroundColor(.orange)
                                Text("Connecter la prise à internet")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            
                            
                        }
                        .padding(20)
                        }
                    
                    TextField("Nouvelle IP de la prise", text: $nouvelle_ip)
                        .font(.title)
                        .cornerRadius(20.0)
                        .frame(width: 300)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.center)
                        .roundedTextField(texte: "Nouvelle IP", colorScheme: colorScheme, color : .darkBlue)
                    
                    Spacer()
                    if connection_state != "Connected"{
                        Text("\(connection_state)")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(height : 80)
                    }
                    Button {
                        checkDeviceStatus(ipAddress: nouvelle_ip)
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
                        .frame(height : 150)
                        .padding(.horizontal)
                        
                    }

                    Spacer()
                }
                
                .navigationBarItems(leading: Button(action: {
                    self.showingAlert = true
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Accueil")
                    }
                })
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Attention"),
                                      message: Text("Toutes les données que vous venez de rentrer seront perdues. \n \n Êtes-vous sûr de vouloir quitter la création de prise ?"),
                                      primaryButton: .destructive(Text("Quitter"), action: {
                                       isQuitting = true
                                      }),
                                      secondaryButton: .cancel(Text("Annuler"))
                                )
                            }
                .navigationTitle("Connexion au réseau")
                .navigationBarTitleDisplayMode(.inline)
                
                .navigationDestination(isPresented: $isQuitting) {
                    MainPage()
                }
                
                .navigationDestination(isPresented: $isPresented) {
                    NouvellePriseView(ip_prise: $nouvelle_ip)
            }
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .onAppear(){
            if nouvelle_ip != ""{
                checkDeviceStatus(ipAddress: nouvelle_ip)
            }
            self.networkServiceDiscovery.startDiscovery()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Attendre 5 secondes pour la découverte de service
                self.tasmotaDevices = self.networkServiceDiscovery.getAddresses()
            }
        }
        
        
    }
}

struct ConnexionReseau2View_Previews: PreviewProvider {
    static var previews: some View {
        ConnexionReseau2View()
            .environmentObject(ReadDatas())
    }
}
