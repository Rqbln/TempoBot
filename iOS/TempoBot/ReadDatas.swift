//
//  ReadDatas.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import Foundation
import Firebase
import SwiftUI

class ReadDatas: ObservableObject{
    
    var ref = Database.database().reference()
    
    @Published var couleurJ: String? = nil
    @Published var couleurJ1: String? = nil
    @Published var date: String? = nil
    @Published var dateJ1: String? = nil
    
    @Published var prises : [prise] = []
    
    func startObservingCouleurJ(){
        ref.child("data/couleurJ").observe(.value) { snapshot in
            if let couleurJ = snapshot.value as? String {
                self.couleurJ = couleurJ
            }
        }
    }
    
    func startObservingCouleurJ1(){
        ref.child("data/couleurJ1").observe(.value) { snapshot in
            if let couleurJ1 = snapshot.value as? String {
                self.couleurJ1 = couleurJ1
            }
        }
    }
    
    func startObservingDate(){
        ref.child("data/date").observe(.value) { snapshot in
            if let date = snapshot.value as? String {
                self.date = date
            }
        }
    }
    
    func startObservingDateJ1(){
        ref.child("data/dateJ1").observe(.value) { snapshot in
            if let dateJ1 = snapshot.value as? String {
                self.dateJ1 = dateJ1
            }
        }
    }
}

