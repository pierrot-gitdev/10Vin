//
//  EditProfileView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var viewModel: WineViewModel
    @EnvironmentObject var authService: FirebaseAuthService
    @Environment(\.dismiss) var dismiss
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var profileImage: UIImage?
    @State private var showPhotoSelection = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Photo de profil
                        VStack(spacing: 16) {
                            ZStack {
                                if let profileImage = profileImage {
                                    Image(uiImage: profileImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(Circle())
                                } else {
                                    Circle()
                                        .fill(WineTheme.wineGradient)
                                        .frame(width: 100, height: 100)
                                        .overlay(
                                            Text(String((viewModel.currentUser?.username.prefix(1) ?? "U").uppercased()))
                                                .font(.system(size: 40, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }
                                
                                // Bouton d'édition
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            showPhotoSelection = true
                                        }) {
                                            Image(systemName: "camera.circle.fill")
                                                .font(.system(size: 32))
                                                .foregroundColor(WineTheme.burgundy)
                                                .background(Circle().fill(Color.white))
                                        }
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                            
                            Button(action: {
                                showPhotoSelection = true
                            }) {
                                Text("settings.editProfile.changePhoto".localized)
                                    .font(.subheadline)
                                    .foregroundColor(WineTheme.burgundy)
                            }
                        }
                        .padding(.top)
                        
                        // Formulaire
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("settings.editProfile.username".localized)
                                    .font(.headline)
                                    .foregroundColor(WineTheme.burgundy)
                                
                                TextField("settings.editProfile.username.placeholder".localized, text: $username)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("settings.editProfile.email".localized)
                                    .font(.headline)
                                    .foregroundColor(WineTheme.burgundy)
                                
                                TextField("settings.editProfile.email.placeholder".localized, text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(WineTheme.burgundy.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("settings.editProfile.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(WineTheme.darkGray)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.save".localized) {
                        saveProfile()
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(WineTheme.burgundy)
                }
            }
            .onAppear {
                username = viewModel.currentUser?.username ?? ""
                email = viewModel.currentUser?.email ?? ""
                // Charger l'image de profil si elle existe
                if let imageURL = viewModel.currentUser?.profileImageURL {
                    loadImage(from: imageURL)
                }
            }
            .sheet(isPresented: $showPhotoSelection) {
                PhotoSelectionView(selectedImage: $profileImage)
            }
        }
    }
    
    private func loadImage(from urlString: String) {
        // À implémenter : charger l'image depuis Firebase Storage
        // Pour l'instant, on garde juste la structure
    }
    
    private func saveProfile() {
        guard var user = viewModel.currentUser else { return }
        user.username = username
        user.email = email
        
        // Sauvegarder l'image si elle a été modifiée
        if let image = profileImage {
            // Convertir l'image en données et sauvegarder
            // À implémenter avec Firebase Storage plus tard
            // Pour l'instant, on peut stocker temporairement
            saveProfileImage(image)
        }
        
        Task {
            do {
                try await authService.updateUser(user)
                viewModel.currentUser = user
                dismiss()
            } catch {
                print("Error saving profile: \(error.localizedDescription)")
                // Erreur silencieuse lors de la mise à jour du profil
            }
        }
    }
    
    private func saveProfileImage(_ image: UIImage) {
        // À implémenter : uploader l'image vers Firebase Storage
        // et mettre à jour user.profileImageURL
        // Pour l'instant, on garde juste la structure
    }
}

#Preview {
    EditProfileView(viewModel: WineViewModel())
}
