//
//  WineTheme.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct WineTheme {
    // Couleurs principales inspirées du vin
    static let burgundy = Color(hex: "#8C1C26") // Rouge bordeaux profond
    static let wineRed = Color(hex: "#B32633") // Rouge vin
    static let darkRed = Color(hex: "#66141F") // Rouge foncé
    static let gold = Color(hex: "#D9A621") // Or (pour les accents)
    static let cream = Color(hex: "#FAF5ED") // Crème (fond clair)
    static let vineyardGreen = Color(hex: "#336633") // Vert vigne
    static let lightGray = Color(hex: "#F2F2F2")
    static let darkGray = Color(hex: "#4D4D4D")
    /// Fond card overlay : crème + léger bordeaux, pour faire ressortir overlay_winecard (blanc/gris).
    static let overlayCardBackground = Color(hex: "#F0E6E0")
    
    // Gradients
    static let wineGradient = LinearGradient(
        colors: [burgundy, wineRed],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let goldGradient = LinearGradient(
        colors: [gold, Color(hex: "#F2BF40")],
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
            return Color(hex: "#F2E6B3") // Jaune paille
        case .rose:
            return Color(hex: "#F2BFCC") // Rose
        case .champagne:
            return WineTheme.gold
        }
    }
}

// Extension pour créer une Color depuis un hexadécimal
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
