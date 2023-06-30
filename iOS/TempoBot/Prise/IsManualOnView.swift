//
//  IsManualOnView.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 23/06/2023.
//

import SwiftUI
import Firebase
struct IsManualOnView: View {
    
    let ref = Database.database().reference()
    @Binding var isPresented : Bool
    @Binding var prise : prise
    @State private var extinctionDate = Date()
    
    @State var showRedButton = false
    @EnvironmentObject var datas : ReadDatas
    @Environment(\.colorScheme) var colorScheme
    
    private var priseRef: DatabaseReference {
        if datas.nomPrise[prise.id.uuidString] != nil {
            return ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing: datas.nomPrise[prise.id.uuidString]!))")
        } else {
            return ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing : prise.id))")
        }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private func startListening() {
        priseRef.child("isManualOn").observe(.value) { snapshot, _ in
            if let value = snapshot.value as? String {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                
                if let date = formatter.date(from: value) {
                    var calendar = Calendar.current
                    calendar.timeZone = TimeZone.current
                    
                    let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
                    
                    if let finalDate = calendar.date(from: currentDateComponents)?.addingTimeInterval(TimeInterval(timeComponents.hour! * 3600 + timeComponents.minute! * 60)) {
                        self.extinctionDate = finalDate
                    }
                } else {
                    print("Could not convert date")
                }
            }
        }
    }

    func checkTime(){
        priseRef.observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.hasChild("isManualOn"){

                    showRedButton = true

                }else{

                    showRedButton = false
                }


            })
    }
    var body: some View {

        
        if isPresented {
            ZStack {
                if colorScheme == .dark {
                    Color.white
                        .opacity(0.2)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            isPresented = false
                        }
                        
                }else{
                    Color.black
                        .opacity(0.5)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            isPresented = false
                        }
                }
                
                VStack {
                    RoundedRectangle(cornerRadius: 40)
                        .foregroundColor(colorScheme == .dark ? .black : .white)
                        .frame(maxWidth: .infinity, maxHeight: 270)
                        .padding()
                        .overlay(
                            VStack {
                                Spacer()
                                Text("Mode manuel")
                                    .font(.system(size : 40))
                                    .bold()
                                    .padding(.top, 40)
                                HStack{
                                    Text("Votre prise s'éteindra à")
                                        .font(.system(size : 26))
                                    DatePicker("", selection: $extinctionDate, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .environment(\.locale, Locale(identifier: "fr"))
                                        .environment(\.sizeCategory, .extraExtraLarge)
                                }

                                
                                
                                if timeRemaining() != ""{
                                    Text("Votre prise s'éteindra dans \(timeRemaining())")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                        .frame(height: 10)
                                        
                                        
                                }else{
                                    Text("")
                                        .foregroundColor(.secondary)
                                        .font(.footnote)
                                        .frame(height: 10)
                                }
                                    
                                HStack(spacing : 0){
                                    
                                    if timeRemaining() != "" {
                                        
                                        
                                        if showRedButton {
                                            Button {
                                                
                                                extinctionDate = .now
                                                withAnimation{
                                                    isPresented = false
                                                }
                                                priseRef.child("isManualOn").removeValue()
                                            } label: {
                                                ZStack{
                                                    RoundedRectangle(cornerRadius: 30, style : .continuous)
                                                        .frame(maxWidth : .infinity, maxHeight: 65)
                                                        .foregroundColor(.red)
                                                        .shadow(color : .red, radius : 10)
                                                        .padding(.horizontal, 10)
                                                        .padding()
                                                    Text("Annuler")
                                                        .font(.system(size: 35))
                                                        .foregroundColor(.white)
                                                        .fontWeight(.semibold)
                                                }
                                                
                                            }
                                            
                                        }
                                    }
                                        Button {
                                            withAnimation{
                                                isPresented = false
                                            }
                                            priseRef.child("isManualOn").setValue(dateFormatter.string(from: extinctionDate))
                                        } label: {
                                            ZStack{
                                                RoundedRectangle(cornerRadius: 30, style : .continuous)
                                                    .frame(maxWidth : .infinity, maxHeight: 65)
                                                    .foregroundColor(timeRemaining() == "" ? .secondary : .darkBlue)
                                                    .shadow(color : timeRemaining() == "" ? .secondary : .darkBlue, radius : 10)
                                                    .padding(.horizontal, showRedButton ? 10 : 40)
                                                    .padding()
                                                Text("Confirmer")
                                                    .font(.system(size: 35))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.semibold)
                                            }
                                            .frame(height : 100)
                                            
                                        }
                                        .disabled(timeRemaining() == "")
                                    
                                }
                                Spacer()
                            }
                            
                            
                    )
                }
                
            }
            .onAppear(){
                startListening()
                checkTime()
            }
        }
    }
    
    func timeRemaining() -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: Date(), to: extinctionDate)
        
        var hour = components.hour  ?? 0
        
        var minute = components.minute ?? 0
        
        if hour < 0{
            hour += 23
        }
        
        if (hour == 0 && minute < 0) {
            hour += 23
        }
        
        if minute < 0 {
            minute += 60
        }
        
        if minute == 0 && hour == 0 {
            return ""
        }else{
            return "\(hour) heures et \(minute) minutes"
        }
    }}



struct IsManualOnView_Previews: PreviewProvider {
    static var previews: some View {
        IsManualOnView(isPresented: .constant(true), prise: .constant(prise(nom: "", creuses_bleu: false, pleines_bleu: false, creuses_blanc: false, pleines_blanc: false, creuses_rouge: false, pleines_rouge: false, isOn: false)))
            .environmentObject(ReadDatas())
    }
}
