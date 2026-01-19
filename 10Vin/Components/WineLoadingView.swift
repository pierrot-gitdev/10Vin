//
//  WineLoadingView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct WineLoadingView: View {
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    
    private let imageNames = [
        "loading_step1",
        "loading_step2",
        "loading_step3",
        "loading_step4"
    ]
    
    private let frameDuration: Double = 0.2
    
    var body: some View {
        ZStack {
            WineTheme.cream
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Animation du verre qui se remplit
                if let image = UIImage(named: imageNames[currentImageIndex]) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        stopAnimation()
        
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            currentImageIndex = (currentImageIndex + 1) % imageNames.count
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

// Vue de chargement avec overlay (pour les vues existantes)
struct WineLoadingOverlay: View {
    @Binding var isLoading: Bool
    
    var body: some View {
        Group {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    WineLoadingContent()
                }
                .transition(.opacity)
                .zIndex(999)
            }
        }
    }
}

// Contenu du loading (réutilisable)
struct WineLoadingContent: View {
    @State private var currentImageIndex = 0
    @State private var timer: Timer?
    
    private let imageNames = [
        "loading_step1",
        "loading_step2",
        "loading_step3",
        "loading_step4"
    ]
    
    private let frameDuration: Double = 0.2
    
    var body: some View {
        VStack(spacing: 24) {
            // Animation du verre qui se remplit
            if let image = UIImage(named: imageNames[currentImageIndex]) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(WineTheme.cream.opacity(0.95))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .onAppear {
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func startAnimation() {
        stopAnimation()
        
        timer = Timer.scheduledTimer(withTimeInterval: frameDuration, repeats: true) { _ in
            currentImageIndex = (currentImageIndex + 1) % imageNames.count
        }
    }
    
    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}

#Preview {
    WineLoadingView()
}
