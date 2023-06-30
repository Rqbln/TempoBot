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
            @State private var verification: String = ""
            
            @State var passwordVisible = false
    @EnvironmentObject var datas : ReadDatas
            @Environment(\.colorScheme) var colorScheme
            var body: some View {
                
                NavigationStack {
                    
                ZStack{
                    
                        VStack(spacing: 20) {
                            Spacer()
                            // Username
                            TextField("Adresse électronique", text: $email)
                            .font(.system(size: 22))
                                .cornerRadius(20.0)
                                .frame(width: 300)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .multilineTextAlignment(.center)
                                .roundedTextField(texte: "Email", colorScheme: colorScheme, color : .secondary)
                        
                            // Password
                            ZStack(alignment: .trailing) {
                                if !passwordVisible {
                                    SecureField("Mot de passe", text: $password)
                                        .font(.system(size: 22))
                                        .cornerRadius(20.0)
                                        .frame(width: 300)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                        .multilineTextAlignment(.center)
                                    
                                        .roundedTextField(texte : "Mot de passe", colorScheme: colorScheme, color : .secondary)
                                }else{
                                    TextField("Mot de passe", text: $password)
                                        .font(.system(size: 22))
                                        .cornerRadius(20.0)
                                        .frame(width: 300)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                        .multilineTextAlignment(.center)
                                    
                                        .roundedTextField(texte : "Mot de passe", colorScheme: colorScheme, color : .secondary)
                                }
                                Button {
                                    
                                        passwordVisible.toggle()
                                } label: {
                                        Image(systemName: passwordVisible ? "eye" : "eye.slash")
                                            .padding(.horizontal, 30)
                                            .foregroundColor(.primary)
                                            .font(.system(size: 24))
                                    
                                }

                            }
                            if verification != "" {
                                Text("\(verification)")
                            }
                            Button {
                            register()
                            } label: {
                                ZStack {
                                    Text("Créer un compte")
                                        .fontWeight(.semibold)
                                        .font(.title2)
                                        .padding()
                                        .foregroundColor(.white)
                                        .zIndex(10)
                                    RoundedRectangle(cornerRadius: 20, style : .continuous)
                                        .frame(maxWidth : .infinity, maxHeight : 65)
                                        .padding(.horizontal)
                                        .foregroundColor(.darkBlue)
                                }
                                    
                            }
                            HStack(spacing : 5) {
                                Text("Vous avez déjà un compte ?")
                                    .multilineTextAlignment(.center)
                                NavigationLink("Connectez-vous", destination : Login())
                                    .foregroundColor(.darkBlue)
                                    .bold()
                            }
                            Spacer()
                            
                        }
                    }
                .navigationTitle("Créer un compte")
                .navigationDestination(isPresented: $isAuth) {
                    Login(retrieve_email: email, retrieve_password: password)
                }
                    
                }
                .navigationBarBackButtonHidden(true)
                    }
    func register(){
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if error != nil{
                print (error!.localizedDescription)
                if error!.localizedDescription == "The email address is already in use by another account." {
                    verification = "Un autre compte utilise déjà cette addresse Email"
                }
            }else{
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                isAuth = true
            }
                }
            }
    
    
        }

struct SignUp_Previews: PreviewProvider {
    static var previews: some View {
        SignUp()
            .environmentObject(ReadDatas())
    }
}
