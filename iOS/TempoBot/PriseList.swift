//
//  PriseList.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 23/06/2023.
//

import SwiftUI
import Firebase
struct PriseList: View {
    @EnvironmentObject var datas : ReadDatas
    let ref = Database.database().reference()
    @Binding var supprimer: Int?

    var body: some View {
                                                ForEach(Array(datas.prises.enumerated()), id: \.element.id) { index, prise in
                                                    let priseRef = datas.nomPrise[prise.id.uuidString] != nil ?
                                                    ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing: datas.nomPrise[prise.id.uuidString]!))") :
                                                    ref.child("data/users").child(String(datas.uid!)).child("prises/\(String(describing : prise.id))")
                                                    
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .foregroundColor((prise.isOn || prise.isManualOn != nil) ? .mint : .secondary)
                                                        .frame(height: 100)
                                                        .overlay(
                                                            HStack{
                                                                Button {
                                                                    supprimer = index
                                                                } label: {
                                                                    Image(systemName: "trash.fill")
                                                                        .foregroundColor(.red)
                                                                        .font(.system(size: 22))
                                                                }
                                                                .actionSheet(isPresented: Binding(get: { supprimer == index }, set: { _ in })) {
                                                                    ActionSheet(title: Text("Supprimer la prise"),
                                                                                message: Text("Êtes-vous sûr de vouloir supprimer cette prise ? Toutes ses données seront effacées."),
                                                                                buttons: [
                                                                                    .destructive(Text("Supprimer"), action: {
                                                                                        priseRef.removeValue()
                                                                                        datas.nomPrise.removeValue(forKey: prise.id.uuidString)
                                                                                        withAnimation {
                                                                                            datas.recuperer_prises()
                                                                                        }
                                                                                        supprimer = nil
                                                                                    }),
                                                                                    .cancel(Text("Annuler"), action: {
                                                                                        supprimer = nil
                                                                                    })
                                                                                ])
                                                                }
                                                                .animation(.easeInOut(duration: 0.7), value: datas.prises)
                                                                
                                                                Spacer()
                                                                Text(prise.nom)
                                                                Spacer()
                                                                NavigationLink(destination: InfoPriseView(prise: $datas.prises[index])) {
                                                                    Image(systemName: "line.horizontal.2.decrease.circle.fill")
                                                                        .foregroundColor(.accentColor)
                                                                }
                                                            }
                                                                .padding()
                                                                .font(.system(size: 25))
                                                        )
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal)
                                
                                                }
                                            
    }
}



struct PriseList_Previews: PreviewProvider {
    static var previews: some View {
        PriseList(supprimer : .constant(0))
            .environmentObject(ReadDatas())
    }
}
