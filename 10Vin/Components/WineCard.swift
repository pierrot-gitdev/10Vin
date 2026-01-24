//
//  WineCard.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct WineCard: View {
    let wine: Wine
    var showFullDetails: Bool = false
    /// Afficher la photo du vin. Mettre à false pour l’overlay profil.
    var showImage: Bool = true
    var spaciousOverlay: Bool = false
    
    private var innerSpacing: CGFloat { spaciousOverlay ? 16 : 12 }
    private var sectionSpacing: CGFloat { spaciousOverlay ? 10 : 6 }
    private var horizontalPadding: CGFloat { spaciousOverlay ? 20 : 16 }
    private var verticalPadding: CGFloat { spaciousOverlay ? 20 : 16 }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo du vin (si disponible et affichage activé)
            if showImage,
               let imageURL = wine.imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                WineImageView(url: url)
                    .frame(height: showFullDetails ? 250 : 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: innerSpacing) {
                // Header avec type et rating
            HStack {
                // Badge type de vin
                HStack(spacing: 6) {
                    Circle()
                        .fill(wine.type.color)
                        .frame(width: 12, height: 12)
                    Text(wine.type.displayName.localized)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(wine.type.color.opacity(0.2))
                .cornerRadius(20)
                
                Spacer()
                
                if let rating = wine.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(WineTheme.gold)
                            .font(.caption)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
            
            // Domaine
            Text(wine.domain)
                .font(spaciousOverlay ? .system(size: 22, weight: .semibold, design: .serif) : WineTheme.headlineFont)
                .foregroundColor(WineTheme.burgundy)
            
            // Infos principales
            VStack(alignment: .leading, spacing: sectionSpacing) {
                if let vintage = wine.vintage {
                    InfoRow(icon: "calendar", text: "\("wine.card.vintage".localized): \(vintage)")
                }
                InfoRow(icon: "map", text: "\("wine.card.region".localized): \(wine.region)")
                InfoRow(icon: "leaf", text: wine.grapeVariety)
            }
            .font(spaciousOverlay ? .body : .subheadline)
            .foregroundColor(WineTheme.darkGray)
            
            // Notes de dégustation (si showFullDetails)
            if showFullDetails && !wine.tastingNotes.isEmpty {
                Divider()
                    .padding(.vertical, spaciousOverlay ? 8 : 4)
                
                Text(wine.tastingNotes)
                    .font(.body)
                    .foregroundColor(WineTheme.darkGray)
                    .lineLimit(nil)
            }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
        .background {
            if spaciousOverlay {
                Color.clear
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct InfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(WineTheme.burgundy.opacity(0.7))
                .frame(width: 16)
            Text(text)
        }
    }
}

#Preview {
    WineCard(
        wine: Wine(
            type: .red,
            grapeVariety: "Pinot Noir",
            domain: "Domaine de la Romanée-Conti",
            vintage: 2018,
            region: "Bourgogne",
            tastingNotes: "Un vin d'exception avec des arômes de cerise et d'épices.",
            rating: 9.5,
            userId: "user1"
        ),
        showFullDetails: true
    )
    .padding()
}
