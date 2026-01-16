//
//  PhotoSelectionView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct PhotoSelectionView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) var dismiss
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(spacing: 24) {
            Text("settings.editProfile.selectPhoto".localized)
                .font(WineTheme.headlineFont)
                .foregroundColor(WineTheme.burgundy)
                .padding(.top, 24)
            
            HStack(spacing: 30) {
                // Galerie
                Button(action: {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 50))
                            .foregroundColor(WineTheme.burgundy)
                        Text("settings.editProfile.gallery".localized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(WineTheme.darkGray)
                    }
                    .frame(width: 140, height: 140)
                    .background(WineTheme.burgundy.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 2)
                    )
                }
                
                // Caméra
                Button(action: {
                    sourceType = .camera
                    showImagePicker = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 50))
                            .foregroundColor(WineTheme.burgundy)
                        Text("settings.editProfile.camera".localized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(WineTheme.darkGray)
                    }
                    .frame(width: 140, height: 140)
                    .background(WineTheme.burgundy.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)
            
            Button("common.cancel".localized) {
                dismiss()
            }
            .font(.body)
            .foregroundColor(WineTheme.darkGray)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
        )
        .padding()
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
    }
}

#Preview {
    PhotoSelectionView(selectedImage: .constant(nil))
}
