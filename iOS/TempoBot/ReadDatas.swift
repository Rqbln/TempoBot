//
//  ReadDatas.swift
//  TempoBot
//
//  Created by Timothé Queriaux on 03/03/2023.
//

import Firebase
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import CoreLocation

class ReadDatas: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var ref = Database.database().reference()
    @Published var uid: String? = nil
    @Published var couleurJ: String? = nil
    @Published var couleurJ1: String? = nil
    @Published var date: String? = nil
    @Published var dateJ1: String? = nil
    @AppStorage("UserIsLoggedIn") var UserIsLoggedIn = false
    @Published var nomPrise: [String : String] = [:]

    @Published var prises: [prise] = []
    
    @Published var ssid: String = "tasmota-"
    
    @Published var HasLoadedDatas = false
    
    private var locationManager: CLLocationManager?

    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()

        if let data = UserDefaults.standard.data(forKey: "Auth") {
            if let decoded = try? JSONDecoder().decode(String.self, from: data) {
                uid = decoded
            }
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            print("No access")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
            //self.ssid = self.getWiFiSsid() ?? "No Wi-Fi"
        @unknown default:
            print("Unknown state")
        }
    }

    func getWiFiSsid() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }

    
    
    func save_uid() {
        if let encoded = try? JSONEncoder().encode(uid) {
            UserDefaults.standard.set(encoded, forKey: "Auth")
        }
    }
    
    func recuperer_prises() {
        var IDprise : String = ""
        self.prises = []
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let ref = Database.database().reference()
            let prisesRef = ref.child("data").child("users").child(String(self.uid!)).child("prises")

            prisesRef.observeSingleEvent(of: .value) { (snapshot) in
                self.prises.removeAll()
                guard snapshot.exists() else { return }
                
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot else { continue }
                    
                    let priseID = childSnapshot.key
                    IDprise = childSnapshot.key
                    let priseRef = prisesRef.child(priseID)
                    
                    priseRef.observeSingleEvent(of: .value) { (snapshot, _) in
                        guard let value = snapshot.value as? [String: Any],
                              let nom = value["nom"] as? String,
                              let creuses_bleu = value["creuses_bleu"] as? Bool,
                              let pleines_bleu = value["pleines_bleu"] as? Bool,
                              let creuses_blanc = value["creuses_blanc"] as? Bool,
                              let pleines_blanc = value["pleines_blanc"] as? Bool,
                              let creuses_rouge = value["creuses_rouge"] as? Bool,
                              let pleines_rouge = value["pleines_rouge"] as? Bool,
                              let isOn = value["isOn"] as? Bool
                            else {
                            print("Erreur lors de la récupération des données. Valeur manquante dans la prise.")
                            return
                        }
                        
                        let joursDeLaSemaine = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"]
                        var jours: [String: String] = [:]
                        for jour in joursDeLaSemaine {
                            if let jourValue = value[jour] as? String {
                                jours[jour] = jourValue
                            }
                        }
                        
                        let isManualOn = value["isManualOn"] as? String
                            
                        

                        let nouvellePrise = prise(nom: nom,
                                                  creuses_bleu: creuses_bleu,
                                                  pleines_bleu: pleines_bleu,
                                                  creuses_blanc: creuses_blanc,
                                                  pleines_blanc: pleines_blanc,
                                                  creuses_rouge: creuses_rouge,
                                                  pleines_rouge: pleines_rouge,
                                                  isOn: isOn,
                                                  isManualOn: isManualOn,
                                                  jours: jours.isEmpty ? nil : jours)
                        
                        self.nomPrise["\(nouvellePrise.id.uuidString)"] = IDprise
                        if !self.prises.contains(where: { $0.id == nouvellePrise.id }) {
                            withAnimation {
                                self.prises.append(nouvellePrise)
                            }
                        }
                    }
                }
            }
        }
    }
}

