//
//  _0VinApp.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI
import FirebaseCore

@main
struct _0VinApp: App {
    @StateObject private var authService = FirebaseAuthService()
    
    init() {
        // Initialiser Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
