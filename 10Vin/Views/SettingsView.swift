//
//  SettingsView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: WineViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showEditProfile = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Section Profil
                        SettingsSection(title: "settings.profile".localized) {
                            Button(action: {
                                showEditProfile = true
                            }) {
                                SettingsRow(
                                    icon: "person.circle",
                                    title: "settings.editProfile".localized,
                                    color: WineTheme.burgundy
                                )
                            }
                            
                            Divider()
                            
                            // Confidentialité
                            VStack(alignment: .leading, spacing: 12) {
                                Text("settings.privacy.title".localized)
                                    .font(.headline)
                                    .foregroundColor(WineTheme.burgundy)
                                    .padding(.horizontal)
                                
                                ForEach(PrivacyLevel.allCases, id: \.self) { level in
                                    PrivacyLevelRow(
                                        level: level,
                                        isSelected: viewModel.currentUser?.privacyLevel == level
                                    ) {
                                        viewModel.updatePrivacyLevel(level)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Section Application
                        SettingsSection(title: "settings.app".localized) {
                            // Langue
                            VStack(alignment: .leading, spacing: 12) {
                                Text("settings.language.title".localized)
                                    .font(.headline)
                                    .foregroundColor(WineTheme.burgundy)
                                    .padding(.horizontal)
                                
                                ForEach(AppLanguage.allCases, id: \.self) { language in
                                    LanguageRow(
                                        language: language,
                                        isSelected: viewModel.appLanguage == language
                                    ) {
                                        viewModel.appLanguage = language
                                        // Ici on pourrait changer la langue de l'app
                                        // Pour l'instant, on stocke juste la préférence
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Section Compte
                        SettingsSection(title: "settings.account".localized) {
                            Button(action: {
                                viewModel.logout()
                                dismiss()
                            }) {
                                SettingsRow(
                                    icon: "arrow.right.square",
                                    title: "settings.logout".localized,
                                    color: .red
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("settings.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(WineTheme.burgundy)
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(viewModel: viewModel)
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(WineTheme.headlineFont)
                .foregroundColor(WineTheme.burgundy)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(WineTheme.darkGray)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
    }
}

struct PrivacyLevelRow: View {
    let level: PrivacyLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName.localized)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(WineTheme.darkGray)
                    
                    Text(level.description.localized)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(WineTheme.burgundy)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? WineTheme.burgundy.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LanguageRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(language.displayName.localized)
                    .font(.body)
                    .foregroundColor(WineTheme.darkGray)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(WineTheme.burgundy)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? WineTheme.burgundy.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView(viewModel: WineViewModel())
}
