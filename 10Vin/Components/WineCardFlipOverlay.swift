//
//  WineCardFlipOverlay.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import SwiftUI

struct WineCardFlipOverlay: View {
    let wine: Wine
    let onDismiss: () -> Void
    @ObservedObject var viewModel: WineViewModel
    
    @State private var flipAngle: Double = 0
    @State private var backgroundOpacity: Double = 0
    
    var body: some View {
        ZStack(alignment: .top) {
            // Fond flouté — Button full-screen : tap en dehors ferme l'overlay
            Button(action: closeOverlay) {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background(.ultraThinMaterial)
            .opacity(backgroundOpacity)
            .ignoresSafeArea()
            
            // Card centrée + croix au-dessus (VStack 320pt pour que tap « autour » ferme)
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: closeOverlay) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)

                    }
                }
                .frame(width: 320)
                .padding(.bottom, 8)
                
                // Carte flip (tap sur la carte ne ferme pas)
                ZStack {
                    ProfileGalleryItemView(wine: wine)
                        .frame(width: 320, height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .rotation3DEffect(
                            .degrees(flipAngle),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.5
                        )
                        .opacity(flipAngle < 90 ? 1 : 0)
                    
                    WineCardOverlayContent(
                        wine: viewModel.wines.first(where: { $0.id == wine.id }) ?? wine
                    )
                    .frame(width: 320, height: 420)
                    .rotation3DEffect(
                        .degrees(flipAngle + 180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .opacity(flipAngle >= 90 ? 1 : 0)
                }
                .scaleEffect(1.0 + (flipAngle / 180) * 0.1)
                .onTapGesture { }
            }
            .frame(width: 320)
            .padding(.top, 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.35)) {
                backgroundOpacity = 1
            }
            withAnimation(.easeInOut(duration: 0.5).delay(0.1)) {
                flipAngle = 180
            }
        }
    }
    
    private func closeOverlay() {
        withAnimation(.easeInOut(duration: 0.4)) {
            flipAngle = 0
            backgroundOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            onDismiss()
        }
    }
}

/// Carte vin overlay : ZStack centré, contenu fixe (pas de ScrollView), infos + overlay_winecard.
private struct WineCardOverlayContent: View {
    let wine: Wine
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Fond blanc + ombre
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            // Infos dans la card
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(wine.type.color)
                            .frame(width: 10, height: 10)
                        Text(wine.type.displayName.localized)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(wine.type.color.opacity(0.2))
                    .cornerRadius(16)
                    
                    Spacer()
                    
                    if let r = wine.rating {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(WineTheme.gold)
                                .font(.caption2)
                            Text(String(format: "%.1f", r))
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Text(wine.domain)
                    .font(.system(size: 20, weight: .semibold, design: .serif))
                    .foregroundColor(WineTheme.burgundy)
                
                VStack(alignment: .leading, spacing: 6) {
                    if let v = wine.vintage {
                        InfoRow(icon: "calendar", text: "\(("wine.card.vintage".localized)): \(v)")
                    }
                    InfoRow(icon: "map", text: "\(("wine.card.region".localized)): \(wine.region)")
                    InfoRow(icon: "leaf", text: wine.grapeVariety)
                }
                .font(.subheadline)
                .foregroundColor(WineTheme.darkGray)
                
                if !wine.tastingNotes.isEmpty {
                    Divider()
                        .padding(.vertical, 4)
                    Text(wine.tastingNotes)
                        .font(.footnote)
                        .foregroundColor(WineTheme.darkGray)
                        .lineLimit(4)
                }
                
                Spacer(minLength: 0)
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            // Asset overlay_winecard en bas à droite (2× plus grand)
            Image("overlay_winecard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 180, maxHeight: 144)
                .padding(12)
        }
        .frame(width: 320, height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
