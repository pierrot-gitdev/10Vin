//
//  WineViewModel.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class WineViewModel: ObservableObject {
    @Published var wines: [Wine] = []
    @Published var feedPosts: [FeedPost] = []
    @Published var currentUser: User?
    @Published var isLoading = false
    
    // Settings
    @Published var appLanguage: AppLanguage = .french
    
    // Filtres
    @Published var selectedWineType: WineType?
    @Published var selectedGrapeVariety: String?
    @Published var selectedRegion: String?
    
    init() {
        // Données de démonstration pour le développement
        loadSampleData()
    }
    
    func loadSampleData() {
        // Données d'exemple pour le développement
        let sampleUser = User(
            id: "user1",
            username: "WineLover",
            email: "wine@example.com",
            privacyLevel: .public
        )
        currentUser = sampleUser
        
        let sampleWines = [
            Wine(
                type: .red,
                grapeVariety: "Pinot Noir",
                domain: "Domaine de la Romanée-Conti",
                vintage: 2018,
                region: "Bourgogne",
                tastingNotes: "Un vin d'exception avec des arômes de cerise et d'épices.",
                rating: 9.5,
                userId: sampleUser.id
            ),
            Wine(
                type: .white,
                grapeVariety: "Chardonnay",
                domain: "Domaine Leflaive",
                vintage: 2020,
                region: "Bourgogne",
                tastingNotes: "Élégant et minéral, avec des notes de beurre et de noisette.",
                rating: 9.0,
                userId: sampleUser.id
            )
        ]
        
        wines = sampleWines
        
        let samplePosts = [
            FeedPost(
                wineId: sampleWines[0].id,
                userId: sampleUser.id,
                username: sampleUser.username,
                likes: [],
                comments: []
            )
        ]
        
        feedPosts = samplePosts
    }
    
    func addWine(_ wine: Wine) {
        wines.append(wine)
        
        // Créer automatiquement un FeedPost pour le vin ajouté
        if let user = currentUser {
            let post = FeedPost(
                wineId: wine.id,
                userId: user.id,
                username: user.username,
                userProfileImageURL: user.profileImageURL,
                likes: [],
                comments: []
            )
            feedPosts.insert(post, at: 0) // Ajouter en haut du feed
        }
    }
    
    func addToWishlist(_ wineId: String) {
        guard var user = currentUser else { return }
        if !user.wishlist.contains(wineId) {
            user.wishlist.append(wineId)
            currentUser = user
        }
    }
    
    func removeFromWishlist(_ wineId: String) {
        guard var user = currentUser else { return }
        user.wishlist.removeAll { $0 == wineId }
        currentUser = user
    }
    
    func likePost(_ postId: String) {
        guard let userId = currentUser?.id,
              let index = feedPosts.firstIndex(where: { $0.id == postId }) else { return }
        
        if feedPosts[index].likes.contains(userId) {
            feedPosts[index].likes.removeAll { $0 == userId }
        } else {
            feedPosts[index].likes.append(userId)
        }
    }
    
    func addComment(_ text: String, to postId: String) {
        guard let userId = currentUser?.id,
              let username = currentUser?.username,
              let index = feedPosts.firstIndex(where: { $0.id == postId }) else { return }
        
        let comment = Comment(userId: userId, username: username, text: text)
        feedPosts[index].comments.append(comment)
    }
    
    func updateUser(_ updatedUser: User) {
        currentUser = updatedUser
    }
    
    func updatePrivacyLevel(_ level: PrivacyLevel) {
        guard var user = currentUser else { return }
        user.privacyLevel = level
        currentUser = user
    }
    
    func logout() {
        // À implémenter avec Firebase plus tard
        print("Logout - À implémenter avec Firebase")
    }
    
    var filteredWines: [Wine] {
        wines.filter { wine in
            (selectedWineType == nil || wine.type == selectedWineType) &&
            (selectedGrapeVariety == nil || wine.grapeVariety == selectedGrapeVariety) &&
            (selectedRegion == nil || wine.region == selectedRegion)
        }
    }
}

enum AppLanguage: String, CaseIterable {
    case french = "fr"
    case english = "en"
    
    var displayName: String {
        switch self {
        case .french: return "settings.language.french"
        case .english: return "settings.language.english"
        }
    }
}
