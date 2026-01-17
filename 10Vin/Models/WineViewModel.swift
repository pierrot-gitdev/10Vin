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
    
    private let firestoreService = FirestoreService()
    
    init() {
        // Les données seront chargées depuis Firebase
    }
    
    func loadData(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Charger les vins de l'utilisateur
            wines = try await firestoreService.getWines(userId: userId)
            
            // Charger les posts du feed (utilisateurs suivis + posts de l'utilisateur)
            if let user = currentUser {
                var followingIds = user.following
                followingIds.append(userId) // Inclure ses propres posts
                feedPosts = try await firestoreService.getPosts(following: followingIds)
            } else {
                feedPosts = try await firestoreService.getPosts()
            }
        } catch {
            print("Error loading data: \(error.localizedDescription)")
            // Erreur silencieuse lors du chargement des données
        }
    }
    
    func addWine(_ wine: Wine) async throws {
        // Sauvegarder dans Firestore
        try await firestoreService.createWine(wine)
        
        // Ajouter localement
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
            
            // Sauvegarder le post dans Firestore
            try await firestoreService.createPost(post)
            
            // Ajouter localement
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
    
    func likePost(_ postId: String) async throws {
        guard let userId = currentUser?.id,
              let index = feedPosts.firstIndex(where: { $0.id == postId }) else { return }
        
        if feedPosts[index].likes.contains(userId) {
            feedPosts[index].likes.removeAll { $0 == userId }
        } else {
            feedPosts[index].likes.append(userId)
        }
        
        // Mettre à jour dans Firestore
        try await firestoreService.updatePost(feedPosts[index])
    }
    
    func addComment(_ text: String, to postId: String) async throws {
        guard let userId = currentUser?.id,
              let username = currentUser?.username,
              let index = feedPosts.firstIndex(where: { $0.id == postId }) else { return }
        
        let comment = Comment(userId: userId, username: username, text: text)
        feedPosts[index].comments.append(comment)
        
        // Mettre à jour dans Firestore
        try await firestoreService.updatePost(feedPosts[index])
    }
    
    func updateUser(_ updatedUser: User) {
        currentUser = updatedUser
    }
    
    func updatePrivacyLevel(_ level: PrivacyLevel) {
        guard var user = currentUser else { return }
        user.privacyLevel = level
        currentUser = user
    }
    
    func logout() throws {
        // Cette fonction sera appelée depuis SettingsView
        // L'authentification est gérée par FirebaseAuthService
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
