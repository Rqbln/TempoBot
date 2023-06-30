//
//  setupPrise.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import Foundation

struct prise: Identifiable, Codable, Equatable {
    var id = UUID()
    var nom: String
    var creuses_bleu: Bool
    var pleines_bleu: Bool
    var creuses_blanc: Bool
    var pleines_blanc: Bool
    var creuses_rouge: Bool
    var pleines_rouge: Bool
    var isOn: Bool
    var isManualOn: String?
    var jours: [String: String]?
    
    init(nom: String, creuses_bleu: Bool, pleines_bleu: Bool, creuses_blanc: Bool, pleines_blanc: Bool, creuses_rouge: Bool, pleines_rouge: Bool, isOn: Bool, isManualOn: String? = nil, jours: [String: String]? = nil) {
        self.nom = nom
        self.creuses_bleu = creuses_bleu
        self.pleines_bleu = pleines_bleu
        self.creuses_blanc = creuses_blanc
        self.pleines_blanc = pleines_blanc
        self.creuses_rouge = creuses_rouge
        self.pleines_rouge = pleines_rouge
        self.isOn = isOn
        self.isManualOn = isManualOn
        self.jours = jours
    }
}

