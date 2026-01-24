//
//  WineImageView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import SwiftUI

struct WineImageView: View {
    let url: URL?
    @State private var image: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Rectangle()
                        .fill(WineTheme.cream)
                    
                    if isLoading {
                        ProgressView()
                            .tint(WineTheme.burgundy)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(WineTheme.burgundy.opacity(0.3))
                    }
                }
            }
        }
        .task(id: url?.absoluteString) {
            guard let url = url else { return }
            await loadImage(from: url)
        }
    }
    
    private func loadImage(from url: URL) async {
        guard image == nil else { return }
        isLoading = true
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.image = uiImage
                    self.isLoading = false
                }
            } else {
                await MainActor.run { self.isLoading = false }
            }
        } catch {
            await MainActor.run { self.isLoading = false }
        }
    }
}
