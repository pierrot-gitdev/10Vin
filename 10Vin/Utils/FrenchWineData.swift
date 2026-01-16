//
//  FrenchWineData.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation

struct FrenchWineData {
    // Liste des principaux cépages français
    static let grapeVarieties: [String] = [
        // Rouges
        "Cabernet Sauvignon",
        "Merlot",
        "Pinot Noir",
        "Syrah",
        "Grenache",
        "Cabernet Franc",
        "Malbec",
        "Cinsault",
        "Carignan",
        "Gamay",
        "Tannat",
        "Mourvèdre",
        "Pinot Meunier",
        "Petit Verdot",
        "Carménère",
        // Blancs
        "Chardonnay",
        "Sauvignon Blanc",
        "Sémillon",
        "Muscat",
        "Viognier",
        "Roussanne",
        "Marsanne",
        "Chenin Blanc",
        "Gewurztraminer",
        "Riesling",
        "Pinot Gris",
        "Pinot Blanc",
        "Ugni Blanc",
        "Colombard",
        "Gros Manseng",
        "Petit Manseng"
    ]
    
    // Liste des principales régions viticoles françaises
    static let regions: [String] = [
        "Alsace",
        "Beaujolais",
        "Bordeaux",
        "Bourgogne",
        "Champagne",
        "Corse",
        "Jura",
        "Languedoc",
        "Loire",
        "Provence",
        "Rhône",
        "Roussillon",
        "Savoie",
        "Sud-Ouest"
    ]
    
    // Années (de 1900 à l'année actuelle)
    static var years: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1900...currentYear).reversed())
    }
}
