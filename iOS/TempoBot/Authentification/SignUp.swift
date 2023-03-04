//
//  SignUp.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 10/02/2023.
//

import SwiftUI
import Firebase

struct SignUp: View {
    
            @State private var email: String = ""
            @State private var password: String = ""
            
            @State private var isAuth: Bool = false
            @State private var verification: String = "pas fait"
            
        
            var body: some View {
                
                NavigationStack {
                    
                ZStack{
                    LinearGradient(colors: [ Color("Violet foncé"), Color("Bleu foncé")], startPoint: .leading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                    
                        VStack(spacing: 20) {
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
                            register()
                            } label: {
                                Text("S'inscrire")
                                    .padding()
                                    .background(.linearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                                    
                            }
                            
                            
                                
                                
                            
                            Spacer()
                            Text("\(verification)")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                            
                            
                            }
                        }
                .navigationBarTitle("SignUp")
                    
                }
                    }
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil{
                print (error!.localizedDescription)
                verification = "Erreur"
            }else{
                verification = "Succès !"
            }
                }
            }
        }

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
    }
}
