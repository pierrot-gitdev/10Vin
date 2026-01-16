//
//  WineTheme.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct WineTheme {
    // Couleurs principales inspirées du vin
    static let burgundy = Color(red: 0.55, green: 0.11, blue: 0.15) // Rouge bordeaux profond
    static let wineRed = Color(red: 0.70, green: 0.15, blue: 0.20) // Rouge vin
    static let darkRed = Color(red: 0.40, green: 0.08, blue: 0.12) // Rouge foncé
    static let gold = Color(red: 0.85, green: 0.65, blue: 0.13) // Or (pour les accents)
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.93) // Crème (fond clair)
    static let vineyardGreen = Color(red: 0.20, green: 0.40, blue: 0.20) // Vert vigne
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let darkGray = Color(red: 0.30, green: 0.30, blue: 0.30)
    
    // Gradients
    static let wineGradient = LinearGradient(
        colors: [burgundy, wineRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [gold, Color(red: 0.95, green: 0.75, blue: 0.25)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Typographie
    static let titleFont = Font.system(size: 28, weight: .bold, design: .serif)
    static let headlineFont = Font.system(size: 20, weight: .semibold, design: .serif)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .default)
    static let captionFont = Font.system(size: 14, weight: .light, design: .default)
}

// Extension pour les couleurs de type de vin
extension WineType {
    var color: Color {
        switch self {
        case .red:
            return WineTheme.burgundy
        case .white:
            return Color(red: 0.95, green: 0.90, blue: 0.70) // Jaune paille
        case .rose:
            return Color(red: 0.95, green: 0.75, blue: 0.80) // Rose
        case .champagne:
            return WineTheme.gold
        }
    }
}
