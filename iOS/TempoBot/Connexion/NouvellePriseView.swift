//
//  NouvellePriseView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import SwiftUI
import Firebase




struct NouvellePriseView: View {
    
    
    let ref = Database.database().reference()

    @EnvironmentObject var datas : ReadDatas
    
    @State var horaireperso = false
    @State var nomPrise = ""
    
    @State var creuses_bleu : Bool = true
    @State var pleines_bleu : Bool = true
    
    @State var creuses_blanc : Bool = true
    @State var pleines_blanc : Bool = true
    
    @State var creuses_rouge : Bool = true
    @State var pleines_rouge : Bool = false
    
    @State var connectedtoMQTT = false
    
    @State var errorMQTT = false
    @State var isQuitting = false
    @State private var showingAlert = false
    
    
    @Binding var ip_prise : String
    func sendRequesttoMQTT(ip : String, nom_prise : String) {
        
        guard let url = URL(string: "http://\(ip)/cm?cmnd=Backlog%20MqttHost%2086.247.10.207%3B%20MqttPort%201883%3B%20Topic%20\(nom_prise)") else {
            print("Invalid URL")
            errorMQTT = true
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("HTTP Request Failed: \(error.localizedDescription)")
                errorMQTT = true
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    connectedtoMQTT = httpResponse.statusCode == 200
               }
            }
        }
        
        task.resume()
    }
    
    var body: some View {
        var nouvellePrise = prise(nom: nomPrise, creuses_bleu: creuses_bleu, pleines_bleu: pleines_bleu, creuses_blanc: creuses_blanc, pleines_blanc: pleines_blanc, creuses_rouge: creuses_rouge, pleines_rouge: pleines_rouge, isOn: false)
        NavigationView {
            ScrollView{
                VStack{
                    Text("Entre 3 et 20 caractères")
                        .font(.footnote)
                        .foregroundColor(.darkBlue)
                    TextField("Nom de la prise", text: $nomPrise)
                        .frame(width: 300)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .cornerRadius(10)
                        .multilineTextAlignment(.center)
                        
                        .underlineTextField()
                    Group{
                        Text("Jours bleus")
                            .padding(.bottom)
                            .font(.title)
                        Toggle("Activer la prise pendant les heures creuses", isOn: $creuses_bleu)
                        Toggle("Activer la prise pendant les heures pleines", isOn: $pleines_bleu)
                    }
                    .font(.system(size : 17))
                    .fontWeight(.semibold)
                    
                    
                    
                    Group{
                        Text("Jours blancs")
                            .padding(.vertical)
                            .font(.title)
                        Toggle("Activer la prise pendant les heures creuses", isOn: $creuses_blanc)
                        Toggle("Activer la prise pendant les heures pleines", isOn: $pleines_blanc)
                    }
                    .font(.system(size : 17))
                    .fontWeight(.semibold)
                    
                    
                    Group{
                        Text("Jours rouges")
                            .padding(.vertical)
                            .font(.title)
                        Toggle("Activer la prise pendant les heures creuses", isOn: $creuses_rouge)
                        Toggle("Activer la prise pendant les heures pleines", isOn: $pleines_rouge)
                    }
                    .font(.system(size : 17))
                    .fontWeight(.semibold)
                }
                .onChange(of: nomPrise, perform: { newValue in
                    if newValue.count > 20 {
                        nomPrise = String(nomPrise.prefix(20))
                    }
                })
                .padding()
                
                    
                    Button(action: {
                        
                        nouvellePrise = prise(nom: nomPrise, creuses_bleu: creuses_bleu, pleines_bleu: pleines_bleu, creuses_blanc: creuses_blanc, pleines_blanc: pleines_blanc, creuses_rouge: creuses_rouge, pleines_rouge: pleines_rouge, isOn: false)
                        let priseRef = ref.child("data/users").child("\(String(describing: datas.uid!))").child("prises").child("\(nouvellePrise.id.uuidString)")
                        

                        nomPrise = ""
                        
                        priseRef.setValue(["nom": nouvellePrise.nom, "creuses_bleu": nouvellePrise.creuses_bleu, "pleines_bleu": nouvellePrise.pleines_bleu, "creuses_blanc": nouvellePrise.creuses_blanc, "pleines_blanc": nouvellePrise.pleines_blanc, "creuses_rouge": nouvellePrise.creuses_rouge, "pleines_rouge": nouvellePrise.pleines_rouge, "isOn": nouvellePrise.isOn] as [String : Any])
                        
                        
                        sendRequesttoMQTT(ip: ip_prise, nom_prise: nouvellePrise.id.uuidString)
                        if errorMQTT{
                            priseRef.removeValue()
                            nomPrise = ""
                        }
                        datas.HasLoadedDatas = false
                    }) {
                        
                        ZStack{
                            RoundedRectangle(cornerRadius: 30, style : .continuous)
                                .frame(maxWidth : .infinity, maxHeight: 105)
                                .foregroundColor(.darkBlue)
                                .shadow(color : .darkBlue, radius : 15, y: 10)
                            Text("Ajouter la prise")
                                .padding()
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .disabled(nomPrise.count < 3)
                
                Text(errorMQTT ? "Erreur : veuillez réessayer" : "")
                    .foregroundColor(.red)
                    Spacer()
                }
           
                      .navigationBarBackButtonHidden(true)
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
                    
            .navigationTitle("Nouvelle prise")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $connectedtoMQTT) {
                MainPage()
            }
            .navigationDestination(isPresented: $isQuitting) {
                MainPage()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationViewStyle(StackNavigationViewStyle())
        
        .onAppear{
            datas.ssid = ""
        }
        }
    }
        

    struct NouvellePriseView_Previews: PreviewProvider {
        static var previews: some View {
            NouvellePriseView(ip_prise : .constant("192.168.1.26"))
                .environmentObject(ReadDatas())
        }
    }

