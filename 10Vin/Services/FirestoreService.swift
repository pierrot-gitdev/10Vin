//
//  FirestoreService.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    private let db = Firestore.firestore()
    
    // MARK: - Users
    
    func createUser(_ user: User) async throws {
        let userDict: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "profileImageURL": user.profileImageURL as Any,
            "winesTasted": user.winesTasted,
            "wishlist": user.wishlist,
            "following": user.following,
            "followers": user.followers,
            "privacyLevel": user.privacyLevel.rawValue
        ]
        
        try await db.collection("users").document(user.id).setData(userDict)
    }
    
    func getUser(userId: String) async throws -> User? {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard document.exists,
              let data = document.data() else {
            return nil
        }
        
        return try decodeUser(from: data)
    }
    
    func updateUser(_ user: User) async throws {
        let userDict: [String: Any] = [
            "username": user.username,
            "email": user.email,
            "profileImageURL": user.profileImageURL as Any,
            "winesTasted": user.winesTasted,
            "wishlist": user.wishlist,
            "following": user.following,
            "followers": user.followers,
            "privacyLevel": user.privacyLevel.rawValue
        ]
        
        try await db.collection("users").document(user.id).updateData(userDict)
    }
    
    // MARK: - Wines
    
    func createWine(_ wine: Wine) async throws {
        let wineDict: [String: Any] = [
            "id": wine.id,
            "type": wine.type.rawValue,
            "grapeVariety": wine.grapeVariety,
            "domain": wine.domain,
            "vintage": wine.vintage as Any,
            "region": wine.region,
            "tastingNotes": wine.tastingNotes,
            "rating": wine.rating as Any,
            "addedDate": Timestamp(date: wine.addedDate),
            "userId": wine.userId
        ]
        
        try await db.collection("wines").document(wine.id).setData(wineDict)
    }
    
    func getWines(userId: String? = nil) async throws -> [Wine] {
        var query: Query = db.collection("wines")
        
        if let userId = userId {
            query = query.whereField("userId", isEqualTo: userId)
        }
        
        let snapshot = try await query.order(by: "addedDate", descending: true).getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try decodeWine(from: document.data(), id: document.documentID)
        }
    }
    
    func getWinesByIds(_ wineIds: [String]) async throws -> [Wine] {
        guard !wineIds.isEmpty else { return [] }
        
        // Récupérer les documents individuellement
        var allWines: [Wine] = []
        
        // Récupérer tous les documents en parallèle
        try await withThrowingTaskGroup(of: Wine?.self) { group in
            for wineId in wineIds {
                group.addTask {
                    do {
                        let document = try await self.db.collection("wines").document(wineId).getDocument()
                        guard document.exists,
                              let data = document.data() else {
                            return nil
                        }
                        return try self.decodeWine(from: data, id: document.documentID)
                    } catch {
                        return nil
                    }
                }
            }
            
            for try await wine in group {
                if let wine = wine {
                    allWines.append(wine)
                }
            }
        }
        
        // Trier par ordre de winesTasted pour préserver l'ordre
        return wineIds.compactMap { id in
            allWines.first { $0.id == id }
        }
    }
    
    func updateWine(_ wine: Wine) async throws {
        let wineDict: [String: Any] = [
            "type": wine.type.rawValue,
            "grapeVariety": wine.grapeVariety,
            "domain": wine.domain,
            "vintage": wine.vintage as Any,
            "region": wine.region,
            "tastingNotes": wine.tastingNotes,
            "rating": wine.rating as Any
        ]
        
        try await db.collection("wines").document(wine.id).updateData(wineDict)
    }
    
    func deleteWine(_ wineId: String) async throws {
        try await db.collection("wines").document(wineId).delete()
    }
    
    // MARK: - Feed Posts
    
    func createPost(_ post: FeedPost) async throws {
        let postDict: [String: Any] = [
            "id": post.id,
            "wineId": post.wineId,
            "userId": post.userId,
            "username": post.username,
            "userProfileImageURL": post.userProfileImageURL as Any,
            "postedDate": Timestamp(date: post.postedDate),
            "likes": post.likes,
            "comments": try post.comments.map { comment in
                [
                    "id": comment.id,
                    "userId": comment.userId,
                    "username": comment.username,
                    "text": comment.text,
                    "date": Timestamp(date: comment.date)
                ]
            }
        ]
        
        try await db.collection("posts").document(post.id).setData(postDict)
    }
    
    func getPosts(following: [String]? = nil) async throws -> [FeedPost] {
        var query: Query = db.collection("posts")
        
        if let following = following, !following.isEmpty {
            // Firestore limite "in" à 10 éléments, donc on doit diviser en lots si nécessaire
            if following.count <= 10 {
                query = query.whereField("userId", in: following)
                let snapshot = try await query.order(by: "postedDate", descending: true).limit(to: 50).getDocuments()
                return try snapshot.documents.compactMap { document in
                    try decodePost(from: document.data(), id: document.documentID)
                }
            } else {
                // Si plus de 10 utilisateurs, diviser en lots
                var allPosts: [FeedPost] = []
                let batchSize = 10
                
                for i in stride(from: 0, to: following.count, by: batchSize) {
                    let endIndex = min(i + batchSize, following.count)
                    let batch = Array(following[i..<endIndex])
                    
                    let batchQuery = db.collection("posts")
                        .whereField("userId", in: batch)
                        .order(by: "postedDate", descending: true)
                        .limit(to: 50)
                    
                    let snapshot = try await batchQuery.getDocuments()
                    let posts = try snapshot.documents.compactMap { document in
                        try decodePost(from: document.data(), id: document.documentID)
                    }
                    allPosts.append(contentsOf: posts)
                }
                
                // Trier par date et limiter à 50
                return Array(allPosts.sorted { $0.postedDate > $1.postedDate }.prefix(50))
            }
        } else {
            // Pas de filtre, charger tous les posts
            let snapshot = try await query.order(by: "postedDate", descending: true).limit(to: 50).getDocuments()
            return try snapshot.documents.compactMap { document in
                try decodePost(from: document.data(), id: document.documentID)
            }
        }
    }
    
    func updatePost(_ post: FeedPost) async throws {
        let postDict: [String: Any] = [
            "likes": post.likes,
            "comments": try post.comments.map { comment in
                [
                    "id": comment.id,
                    "userId": comment.userId,
                    "username": comment.username,
                    "text": comment.text,
                    "date": Timestamp(date: comment.date)
                ]
            }
        ]
        
        try await db.collection("posts").document(post.id).updateData(postDict)
    }
    
    // MARK: - Decoders
    
    private func decodeUser(from data: [String: Any]) throws -> User {
        guard let id = data["id"] as? String,
              let username = data["username"] as? String,
              let email = data["email"] as? String else {
            throw FirestoreError.invalidData
        }
        
        return User(
            id: id,
            username: username,
            email: email,
            profileImageURL: data["profileImageURL"] as? String,
            winesTasted: data["winesTasted"] as? [String] ?? [],
            wishlist: data["wishlist"] as? [String] ?? [],
            following: data["following"] as? [String] ?? [],
            followers: data["followers"] as? [String] ?? [],
            privacyLevel: PrivacyLevel(rawValue: data["privacyLevel"] as? String ?? "public") ?? .public
        )
    }
    
    private func decodeWine(from data: [String: Any], id: String) throws -> Wine? {
        guard let typeString = data["type"] as? String,
              let type = WineType(rawValue: typeString),
              let grapeVariety = data["grapeVariety"] as? String,
              let domain = data["domain"] as? String,
              let region = data["region"] as? String,
              let tastingNotes = data["tastingNotes"] as? String,
              let timestamp = data["addedDate"] as? Timestamp,
              let userId = data["userId"] as? String else {
            return nil
        }
        
        return Wine(
            id: id,
            type: type,
            grapeVariety: grapeVariety,
            domain: domain,
            vintage: data["vintage"] as? Int,
            region: region,
            tastingNotes: tastingNotes,
            rating: data["rating"] as? Double,
            addedDate: timestamp.dateValue(),
            userId: userId
        )
    }
    
    private func decodePost(from data: [String: Any], id: String) throws -> FeedPost? {
        guard let wineId = data["wineId"] as? String,
              let userId = data["userId"] as? String,
              let username = data["username"] as? String,
              let timestamp = data["postedDate"] as? Timestamp else {
            return nil
        }
        
        let commentsData = data["comments"] as? [[String: Any]] ?? []
        let comments = try commentsData.compactMap { commentData -> Comment? in
            guard let commentId = commentData["id"] as? String,
                  let commentUserId = commentData["userId"] as? String,
                  let commentUsername = commentData["username"] as? String,
                  let commentText = commentData["text"] as? String,
                  let commentTimestamp = commentData["date"] as? Timestamp else {
                return nil
            }
            
            return Comment(
                id: commentId,
                userId: commentUserId,
                username: commentUsername,
                text: commentText,
                date: commentTimestamp.dateValue()
            )
        }
        
        return FeedPost(
            id: id,
            wineId: wineId,
            userId: userId,
            username: username,
            userProfileImageURL: data["userProfileImageURL"] as? String,
            postedDate: timestamp.dateValue(),
            likes: data["likes"] as? [String] ?? [],
            comments: comments
        )
    }
}

enum FirestoreError: LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Invalid data format"
        }
    }
}
