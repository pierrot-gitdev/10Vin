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
    @State private var selectedWine: Wine?
    
    enum ProfileTab {
        case tasted
        case wishlist
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Header profil
                            ProfileHeaderView(user: viewModel.currentUser)
                                .padding()
                            
                            // Sélecteur d'onglets
                            ProfileTabSelector(selectedTab: $selectedTab)
                            
                            // Titre galerie + grille 3 colonnes
                            VStack(alignment: .leading, spacing: 12) {
                                Text("profile.gallery.title".localized)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                
                                ProfileGalleryGrid(
                                    wines: displayedWines,
                                    availableWidth: geometry.size.width,
                                    horizontalPadding: 16,
                                    onWineTap: { selectedWine = $0 }
                                )
                            }
                            .padding(.top, 8)
                        }
                    }
                }
            }
            .overlay {
                if let wine = selectedWine {
                    WineCardFlipOverlay(wine: wine, onDismiss: { selectedWine = nil }, viewModel: viewModel)
                }
            }
            .navigationTitle("profile.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // Icône notification (sans action pour l'instant)
                        Image(systemName: "bell.fill")
                            .foregroundColor(WineTheme.darkGray)
                            .font(.title3)
                        
                        Button(action: {
                            showSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(WineTheme.darkGray)
                                .font(.title3)
                        }
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
        HStack(alignment: .top, spacing: 16) {
            // Photo de profil (gauche)
            Group {
                if let imageURL = user?.profileImageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                    AsyncImageView(url: url, size: 80, fallbackInitial: user?.username.first.map { String($0) })
                } else {
                    Circle()
                        .fill(WineTheme.wineGradient)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(String((user?.username.prefix(1) ?? "U").uppercased()))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                        )
                }
            }
            
            // Nom + stats (droite)
            VStack(alignment: .leading, spacing: 12) {
                Text(user?.username ?? "User")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                
                if let user = user {
                    HStack(spacing: 0) {
                        // Following
                        ProfileStatView(
                            count: user.following.count,
                            label: "profile.following".localized
                        )
                        
                        Rectangle()
                            .fill(WineTheme.darkGray.opacity(0.3))
                            .frame(width: 1, height: 32)
                        
                        // Followers
                        ProfileStatView(
                            count: user.followers.count,
                            label: "profile.followers".localized
                        )
                        
                        Rectangle()
                            .fill(WineTheme.darkGray.opacity(0.3))
                            .frame(width: 1, height: 32)
                        
                        // 10Vino (nombre de vins dans la galerie de dégust)
                        ProfileStatView(
                            count: user.winesTasted.count,
                            label: "profile.10vino".localized
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        )
    }
}

struct ProfileStatView: View {
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Text(label)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.black.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileTabSelector: View {
    @Binding var selectedTab: ProfileView.ProfileTab
    
    var body: some View {
        HStack(spacing: 12) {
            ProfileTabButton(
                title: "profile.tab.tasted".localized,
                isSelected: selectedTab == .tasted
            ) {
                selectedTab = .tasted
            }
            
            ProfileTabButton(
                title: "profile.tab.wishlist".localized,
                isSelected: selectedTab == .wishlist
            ) {
                selectedTab = .wishlist
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

struct ProfileTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : WineTheme.burgundy)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? WineTheme.burgundy : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(WineTheme.burgundy, lineWidth: isSelected ? 0 : 1)
                )
        }
    }
}

/// Hauteur fixe des cellules de la galerie profil (placeholders / photos).
private let profileGalleryCellHeight: CGFloat = 132

/// Grille 3 colonnes avec GeometryReader : largeur adaptée au téléphone, padding latéral 16.
/// Hauteur fixe 132 pt. Les images occupent toute la largeur allouée à chaque cellule.
struct ProfileGalleryGrid: View {
    let wines: [Wine]
    let availableWidth: CGFloat
    let horizontalPadding: CGFloat
    let onWineTap: (Wine) -> Void
    
    private let spacing: CGFloat = 8
    
    private var cellWidth: CGFloat {
        let totalPadding = horizontalPadding * 2
        let width = availableWidth - totalPadding
        let w = (width - spacing * 2) / 3
        return max(1, w)
    }
    
    private var columns: [GridItem] {
        [
            GridItem(.fixed(cellWidth), spacing: spacing),
            GridItem(.fixed(cellWidth), spacing: spacing),
            GridItem(.fixed(cellWidth), spacing: spacing)
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(wines) { wine in
                Button {
                    onWineTap(wine)
                } label: {
                    ProfileGalleryItemView(wine: wine)
                        .frame(width: cellWidth, height: profileGalleryCellHeight)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, horizontalPadding)
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
