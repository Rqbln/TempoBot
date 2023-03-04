//
//  setupJour.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 10/02/2023.
//

import SwiftUI
import Firebase


struct jour{
    var couleur_jour : String
    var date : String
    var couleur : Color
    var icone : Image
    
    
    init(couleur: Color, date : String, couleur_jour: String) {
        self.couleur = couleur
        self.date = date
        self.couleur_jour = "Jour " + couleur_jour
        self.icone = couleur_jour == "rouge" ? Image(systemName: "nosign") : Image(systemName: "checkmark")
    }
}
