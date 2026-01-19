//
//  AsyncImageView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct AsyncImageView: View {
    let url: URL
    let size: CGFloat
    let fallbackInitial: String?
    @State private var image: UIImage?
    @State private var isLoading = false
    
    init(url: URL, size: CGFloat, fallbackInitial: String? = nil) {
        self.url = url
        self.size = size
        self.fallbackInitial = fallbackInitial
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(WineTheme.wineGradient)
                    .frame(width: size, height: size)
                    .overlay {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else if let initial = fallbackInitial {
                            Text(initial.uppercased())
                                .font(.system(size: size * 0.4, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        guard image == nil else { return }
        isLoading = true
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        self.image = uiImage
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
}
