//
//  ProfileView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: WineViewModel
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var selectedTab: ProfileTab = .tasted
    @State private var showSettings = false
    
    enum ProfileTab {
        case tasted
        case wishlist
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header profil
                    ProfileHeaderView(user: viewModel.currentUser)
                        .padding()
                    
                    // Sélecteur d'onglets
                    ProfileTabSelector(selectedTab: $selectedTab)
                    
                    // Contenu
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            ForEach(displayedWines) { wine in
                                NavigationLink(destination: WineDetailView(wine: wine, viewModel: viewModel)) {
                                    WineCard(wine: wine)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("profile.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(WineTheme.burgundy)
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(viewModel: viewModel)
                    .environmentObject(authService)
            }
            .onAppear {
                // Recharger les données quand la vue apparaît
                if let userId = authService.currentUser?.id {
                    Task {
                        await viewModel.loadData(userId: userId)
                    }
                }
            }
        }
    }
    
    private var displayedWines: [Wine] {
        let userWines = viewModel.wines.filter { $0.userId == viewModel.currentUser?.id }
        
        switch selectedTab {
        case .tasted:
            return userWines
        case .wishlist:
            guard let wishlist = viewModel.currentUser?.wishlist else { return [] }
            return userWines.filter { wishlist.contains($0.id) }
        }
    }
}

struct ProfileHeaderView: View {
    let user: User?
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(WineTheme.wineGradient)
                .frame(width: 80, height: 80)
                .overlay(
                    Text(String((user?.username.prefix(1) ?? "U").uppercased()))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                )
            
            Text(user?.username ?? "User")
                .font(WineTheme.headlineFont)
                .foregroundColor(WineTheme.burgundy)
            
            if let user = user {
                Text("profile.winesCount".localized.replacingOccurrences(of: "%d", with: "\(user.winesTasted.count)"))
                    .font(.subheadline)
                    .foregroundColor(WineTheme.darkGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct ProfileTabSelector: View {
    @Binding var selectedTab: ProfileView.ProfileTab
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "profile.winesTasted".localized,
                isSelected: selectedTab == .tasted
            ) {
                selectedTab = .tasted
            }
            
            TabButton(
                title: "profile.wishlist".localized,
                isSelected: selectedTab == .wishlist
            ) {
                selectedTab = .wishlist
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? WineTheme.burgundy : WineTheme.darkGray)
                
                Rectangle()
                    .fill(isSelected ? WineTheme.burgundy : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct WineDetailView: View {
    let wine: Wine
    @ObservedObject var viewModel: WineViewModel
    @Environment(\.dismiss) var dismiss
    
    var isInWishlist: Bool {
        viewModel.currentUser?.wishlist.contains(wine.id) ?? false
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                WineCard(wine: wine, showFullDetails: true)
                    .padding()
                
                // Bouton wishlist
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isInWishlist ? WineTheme.burgundy.opacity(0.2) : WineTheme.burgundy)
                    .foregroundColor(isInWishlist ? WineTheme.burgundy : .white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .background(WineTheme.cream)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView(viewModel: WineViewModel())
}
