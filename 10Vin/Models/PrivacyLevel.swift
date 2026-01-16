//
//  PrivacyLevel.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation

enum PrivacyLevel: String, Codable, CaseIterable {
    case `public` = "public"
    case `private` = "private"
    case secret = "secret"
    
    var displayName: String {
        switch self {
        case .public: return "settings.privacy.public"
        case .private: return "settings.privacy.private"
        case .secret: return "settings.privacy.secret"
        }
    }
    
    var description: String {
        switch self {
        case .public: return "settings.privacy.public.description"
        case .private: return "settings.privacy.private.description"
        case .secret: return "settings.privacy.secret.description"
        }
    }
}
