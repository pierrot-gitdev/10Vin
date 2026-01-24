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
    
    private var isInWishlist: Bool {
        viewModel.currentUser?.wishlist.contains(wine.id) ?? false
    }
    
    var body: some View {
        ZStack {
            // Fond flouté
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .opacity(backgroundOpacity)
                .ignoresSafeArea()
                .onTapGesture { }
            
            // Carte flip
            ZStack {
                // Face avant : photo / placeholder
                ProfileGalleryItemView(wine: wine)
                    .frame(maxWidth: 320, maxHeight: 320)
                    .cornerRadius(16)
                    .rotation3DEffect(
                        .degrees(flipAngle),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .opacity(flipAngle < 90 ? 1 : 0)
                
                // Face arrière : carte vin complète (vin du viewModel pour avoir imageURL à jour)
                WineCardOverlayContent(
                    wine: viewModel.wines.first(where: { $0.id == wine.id }) ?? wine,
                    viewModel: viewModel,
                    isInWishlist: isInWishlist
                )
                    .frame(maxWidth: 320)
                    .rotation3DEffect(
                        .degrees(flipAngle + 180),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.5
                    )
                    .opacity(flipAngle >= 90 ? 1 : 0)
            }
            .scaleEffect(1.0 + (flipAngle / 180) * 0.1)
            
            // Icône fermer (croix)
            VStack {
                HStack {
                    Spacer()
                    Button(action: closeOverlay) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.black.opacity(0.5)))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
                Spacer()
            }
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

/// Contenu de la face « dos » : WineCard + bouton wishlist.
private struct WineCardOverlayContent: View {
    let wine: Wine
    @ObservedObject var viewModel: WineViewModel
    let isInWishlist: Bool
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                WineCard(wine: wine, showFullDetails: true, showImage: false)
                    .id(wine.id)
                    .frame(width: 320)
                
                Button(action: {
                    if isInWishlist {
                        viewModel.removeFromWishlist(wine.id)
                    } else {
                        viewModel.addToWishlist(wine.id)
                    }
                }) {
                    HStack {
                        Image(systemName: isInWishlist ? "heart.fill" : "heart")
                        Text(isInWishlist ? "profile.wishlist.remove".localized : "profile.wishlist.add".localized)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isInWishlist ? WineTheme.burgundy.opacity(0.2) : WineTheme.burgundy)
                    .foregroundColor(isInWishlist ? WineTheme.burgundy : .white)
                    .cornerRadius(12)
                }
            }
            .frame(width: 320)
            .padding()
        }
        .frame(maxWidth: 320, maxHeight: 480)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
