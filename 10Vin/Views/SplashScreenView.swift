//
//  SplashScreenView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var opacity: Double = 0.0
    
    var body: some View {
        ZStack {
            Image("App_background")
                .resizable()
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Logo de l'app
                    Image("AppLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(opacity)
                
                // Nom de l'app (optionnel)
                Text("10Vin")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundColor(WineTheme.cream)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                isAnimating = true
                opacity = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
