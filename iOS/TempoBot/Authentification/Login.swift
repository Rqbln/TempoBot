//
//  Login.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 10/02/2023.
//

import SwiftUI
import Firebase

struct Login: View {
    
            @State private var email: String = ""
            @State private var password: String = ""
            
            @State private var isAuth: Bool = false
            @State private var verification: String = "pas fait"
            
            @State private var UserIsLoggedIn: Bool = false
            let auth = [
                    "": "",
                    "username2": "password2"
                ]
            
            var body: some View {
                
                NavigationStack {
                    
                ZStack{
                    LinearGradient(colors: [ Color("Violet foncé"), Color("Bleu foncé")], startPoint: .leading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20){
                        Spacer()
                            // Username
                            TextField("Adresse électronique", text: $email)
                                .padding()
                                .background()
                                .cornerRadius(20.0)
                                .frame(width: 300)
                                .autocorrectionDisabled()
                        
                            // Password
                            SecureField("Mot de passe", text: $password)
                                .padding()
                                .background()
                                .cornerRadius(20.0)
                                .frame(width: 300)
                                .autocorrectionDisabled()
                        
                        Button {
                        login()
                        } label: {
                            Text("Se connecter")
                                .padding()
                                .background(.linearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(15)
                                .foregroundColor(.white)
                                
                        }
                        
                            NavigationLink("Vous n'avez pas de compte? Créez-en un", destination: SignUp())
                        
                        Spacer()
                        Text("\(verification)")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            }
                        }
                                    
                .navigationBarTitle("Login")
        
                }
                
                }
    func login(){
        Auth.auth().signIn(withEmail: email, password: password){result, error in
            if error != nil{
                print(error!.localizedDescription)
                verification = "Erreur"
            }else{
                UserIsLoggedIn = true
                verification = "Succès"
            }
        }
            }
        }

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login()
    }
}
