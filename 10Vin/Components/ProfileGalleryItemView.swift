//
//  ProfileGalleryItemView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import SwiftUI

/// Représente un vin dans la galerie profil : photo de dégustation ou placeholder.
/// Placeholder blanc pour vin blanc, rouge pour les autres types.
struct ProfileGalleryItemView: View {
    let wine: Wine
    
    private var placeholderName: String {
        wine.type == .white ? "placeholder_white" : "placeholder_red"
    }
    
    var body: some View {
        Group {
            if let imageURL = wine.imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                WineImageView(url: url)
            } else {
                Image(placeholderName)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

#Preview {
    ProfileGalleryItemView(
        wine: Wine(
            type: .red,
            grapeVariety: "Pinot Noir",
            domain: "Test",
            region: "Bourgogne",
            tastingNotes: "",
            userId: "u1"
        )
    )
    .frame(width: 160, height: 132)
}
