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
    private let storageService = FirebaseStorageService()
    
    init() {
        // Les données seront chargées depuis Firebase
    }
    
    func loadData(userId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Charger d'abord l'utilisateur depuis Firestore
            if let user = try await firestoreService.getUser(userId: userId) {
                currentUser = user
                
                // Charger les vins goûtés par l'utilisateur en utilisant les IDs de winesTasted
                if !user.winesTasted.isEmpty {
                    wines = try await firestoreService.getWinesByIds(user.winesTasted)
                } else {
                    wines = []
                }
            } else {
                // Si l'utilisateur n'existe pas, charger les vins par userId comme fallback
                wines = try await firestoreService.getWines(userId: userId)
            }
            
            // Charger les posts du feed (utilisateurs suivis + posts de l'utilisateur)
            var posts: [FeedPost] = []
            if let user = currentUser {
                // Toujours inclure ses propres posts même s'il ne suit personne
                var followingIds = user.following
                if !followingIds.contains(userId) {
                    followingIds.append(userId)
                }
                posts = try await firestoreService.getPosts(following: followingIds)
            } else {
                // Si pas d'utilisateur, charger tous les posts
                posts = try await firestoreService.getPosts()
            }
            feedPosts = posts
            
            // Charger tous les vins associés aux posts du feed
            let feedWineIds = posts.map { $0.wineId }
            let uniqueWineIds = Array(Set(feedWineIds))
            
            // Charger les vins du feed qui ne sont pas déjà dans wines
            let existingWineIds = Set(wines.map { $0.id })
            let missingWineIds = uniqueWineIds.filter { !existingWineIds.contains($0) }
            
            if !missingWineIds.isEmpty {
                let feedWines = try await firestoreService.getWinesByIds(missingWineIds)
                wines.append(contentsOf: feedWines)
            }
        } catch {
            print("Error loading data: \(error.localizedDescription)")
            // Erreur silencieuse lors du chargement des données
        }
    }
    
    func addWine(_ wine: Wine, image: UIImage? = nil) async throws {
        guard var user = currentUser else {
            throw NSError(domain: "WineViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        var wineToSave = wine
        
        // Upload l'image si elle existe
        if let image = image {
            do {
                let imageURL = try await storageService.uploadWineImage(image, wineId: wine.id)
                wineToSave.imageURL = imageURL
            } catch {
                // Si l'upload échoue, on continue sans l'image plutôt que de bloquer la création du vin
                // L'utilisateur pourra toujours ajouter une photo plus tard
            }
        }
        
        // Sauvegarder le vin dans Firestore
        try await firestoreService.createWine(wineToSave)
        
        // Ajouter le vin à la liste des vins goûtés de l'utilisateur
        if !user.winesTasted.contains(wine.id) {
            user.winesTasted.append(wine.id)
            // Mettre à jour l'utilisateur dans Firestore
            try await firestoreService.updateUser(user)
        }
        
        // Recharger l'utilisateur depuis Firestore pour avoir la version à jour
        if let updatedUser = try await firestoreService.getUser(userId: user.id) {
            currentUser = updatedUser
        } else {
            // Si le rechargement échoue, utiliser la version locale mise à jour
            currentUser = user
        }
        
        // Ajouter localement seulement si le vin n'existe pas déjà
        if !wines.contains(where: { $0.id == wineToSave.id }) {
            wines.append(wineToSave)
        }
        
        // Créer automatiquement un FeedPost pour le vin ajouté
        let post = FeedPost(
            wineId: wineToSave.id,
            userId: user.id,
            username: user.username,
            userProfileImageURL: user.profileImageURL,
            likes: [],
            comments: []
        )
        
        // Sauvegarder le post dans Firestore
        do {
            try await firestoreService.createPost(post)
            
            // Ajouter localement seulement si le post n'existe pas déjà
            if !feedPosts.contains(where: { $0.id == post.id }) {
                feedPosts.insert(post, at: 0) // Ajouter en haut du feed
            }
        } catch {
            // Ne pas bloquer si la création du post échoue, le vin est déjà sauvegardé
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
