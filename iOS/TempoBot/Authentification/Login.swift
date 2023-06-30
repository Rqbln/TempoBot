//
//  Login.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 10/02/2023.
//

import SwiftUI
import Firebase

extension Color {
    static let darkBlue = Color(red: 60 / 255, green: 60 / 255, blue: 230 / 255)

}

extension View {
    func underlineTextField() -> some View {
        self
            .padding(.vertical, 10)
            .overlay(Rectangle().frame(height: 2).padding(.top, 35))
            .foregroundColor(.darkBlue)
            .padding(.bottom, 10)
    }
}

extension View {
    func roundedTextField(texte : String, colorScheme: ColorScheme, color : Color) -> some View {
        return ZStack{
            self
            
            RoundedRectangle(cornerRadius: 20, style : .continuous)
                .stroke()
                .foregroundColor(color)
                .frame(maxWidth : .infinity, maxHeight : 65)
                .padding(.horizontal)
                
            
            HStack {
                Text("\(texte)")
                    .font(.system(size : 22))
                    .foregroundColor(color)
                   
                    .padding(.horizontal)
                    .background(colorScheme == .dark ? .black : .white)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 70)
                    .cornerRadius(15)
                Spacer()
                    .zIndex(1000)
            }
        }
    }
}



struct Login: View {
    
    @EnvironmentObject var datas : ReadDatas
    var retrieve_email : String = ""
    var retrieve_password : String = ""
            @State private var email: String = ""
            @State private var password: String = ""
            @State private var verification: String = ""
            
            @State var passwordVisible = false
    @Environment(\.colorScheme) var colorScheme
            var body: some View {
                
                NavigationStack{
                    
                ZStack{
                    
                    
                    VStack(spacing: 20){
                        Spacer()
                            // Username
                            TextField("Adresse électronique", text: $email)
                            .font(.system(size: 22))
                                .cornerRadius(20.0)
                                .frame(width: 300)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .multilineTextAlignment(.center)
                                .roundedTextField(texte : "Email", colorScheme: colorScheme, color : .secondary)
                        
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
                                        .font(.title2)
                                
                            }

                        }
                        
                        HStack{
                            Spacer()
                            Text("Mot de passe oublié ?")
                                .padding(.horizontal)
                                .foregroundColor(.darkBlue)
                                .bold()
                        }
                        Button {
                            
                        login()
                        } label: {
                            ZStack {
                                Text("Se connecter")
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
                            Text("Vous n'avez pas de compte ?")
                            NavigationLink("Créez-en un", destination : SignUp())
                                .foregroundColor(.darkBlue)
                                .bold()
                        }
                            

                        Text("\(verification)")
                            .foregroundColor(verification == "Erreur : Vérifier votre mot de passe et votre adresse électronique" ? .red : .green)
                            .font(.caption)
                        
                        Spacer()
                        
        
                            }
                        }
                                    
                .navigationTitle("Se connecter")
                .navigationDestination(isPresented: $datas.UserIsLoggedIn) {
                        MainPage()
                    }
                .onAppear(){
                    email = retrieve_email
                    password = retrieve_password
                }
                }
                .navigationBarBackButtonHidden(true)
                
            
            }
        
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if error != nil {
                print(error!.localizedDescription)
                verification = "Erreur : Vérifier votre mot de passe et votre adresse électronique"
            } else {
                    datas.uid = Auth.auth().currentUser?.uid
                    verification = ""
                    email = ""
                    password = ""
                    datas.save_uid()
                    datas.prises = []
                    datas.UserIsLoggedIn = true   
            }
        }
    }
}
    

struct Login_Previews: PreviewProvider {
    static var previews: some View {
        Login(retrieve_email: "", retrieve_password: "").environmentObject(ReadDatas())
    }
}
