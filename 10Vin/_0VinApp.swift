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
    @State private var showSplash = true
    
    init() {
        // Initialiser Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    // Afficher la vue appropriée selon l'état d'authentification
                    if authService.isAuthenticated {
                        MainTabView()
                            .environmentObject(authService)
                            .transition(.opacity)
                    } else {
                        LoginView()
                            .environmentObject(authService)
                            .transition(.opacity)
                    }
                }
            }
            .onAppear {
                // Masquer le splash screen après un délai
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
