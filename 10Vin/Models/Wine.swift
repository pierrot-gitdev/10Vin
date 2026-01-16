//
//  Wine.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation

enum WineType: String, Codable, CaseIterable {
    case red = "red"
    case white = "white"
    case rose = "rose"
    case champagne = "champagne"
    
    var displayName: String {
        switch self {
        case .red: return "wine.type.red"
        case .white: return "wine.type.white"
        case .rose: return "wine.type.rose"
        case .champagne: return "wine.type.champagne"
        }
    }
}

struct Wine: Identifiable, Codable {
    let id: String
    var type: WineType
    var grapeVariety: String // Cépage
    var domain: String // Domaine
    var vintage: Int? // Millésime
    var region: String // Région
    var tastingNotes: String // Note sur la dégustation
    var rating: Double? // Note sur 10
    var addedDate: Date
    var userId: String
    
    init(
        id: String = UUID().uuidString,
        type: WineType,
        grapeVariety: String,
        domain: String,
        vintage: Int? = nil,
        region: String,
        tastingNotes: String,
        rating: Double? = nil,
        addedDate: Date = Date(),
        userId: String
    ) {
        self.id = id
        self.type = type
        self.grapeVariety = grapeVariety
        self.domain = domain
        self.vintage = vintage
        self.region = region
        self.tastingNotes = tastingNotes
        self.rating = rating
        self.addedDate = addedDate
        self.userId = userId
    }
}
