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
            "usernameLower": user.username.lowercased(),
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

    func getUsersByIds(_ userIds: [String]) async throws -> [User] {
        guard !userIds.isEmpty else { return [] }
        var allUsers: [User] = []

        try await withThrowingTaskGroup(of: User?.self) { group in
            for userId in userIds {
                group.addTask {
                    do {
                        let document = try await self.db.collection("users").document(userId).getDocument()
                        guard document.exists,
                              let data = document.data() else {
                            return nil
                        }
                        return try self.decodeUser(from: data)
                    } catch {
                        return nil
                    }
                }
            }

            for try await user in group {
                if let user = user {
                    allUsers.append(user)
                }
            }
        }

        return userIds.compactMap { id in
            allUsers.first { $0.id == id }
        }
    }

    // MARK: - Wishlist (subcollection)
    
    func getWishlistIds(userId: String) async throws -> [String] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("wishlist")
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
    
    func addWineToWishlist(userId: String, wineId: String, recommendedBy: String? = nil) async throws {
        var data: [String: Any] = [
            "id": wineId,
            "createdAt": FieldValue.serverTimestamp()
        ]
        if let recommendedBy = recommendedBy {
            data["recommendedBy"] = recommendedBy
        }
        try await db.collection("users").document(userId)
            .collection("wishlist").document(wineId)
            .setData(data)
    }
    
    func removeWineFromWishlist(userId: String, wineId: String) async throws {
        try await db.collection("users").document(userId)
            .collection("wishlist").document(wineId)
            .delete()
    }
    
    func updateUser(_ user: User) async throws {
        let userDict: [String: Any] = [
            "username": user.username,
            "usernameLower": user.username.lowercased(),
            "email": user.email,
            "profileImageURL": user.profileImageURL as Any,
            "winesTasted": user.winesTasted,
            "wishlist": user.wishlist,
            "privacyLevel": user.privacyLevel.rawValue
        ]
        
        try await db.collection("users").document(user.id).updateData(userDict)
    }

    func searchUsers(by query: String, limit: Int = 20) async throws -> [User] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        
        var results: [User] = []
        var seen = Set<String>()
        
        func appendUnique(_ users: [User]) {
            for user in users {
                guard !seen.contains(user.id) else { continue }
                results.append(user)
                seen.insert(user.id)
                if results.count >= limit { return }
            }
        }
        
        // 1) Recherche principale sur usernameLower (case-insensitive)
        let lowerResults = try await queryUsers(field: "usernameLower", query: trimmed.lowercased(), limit: limit)
        appendUnique(lowerResults)
        
        // 2) Fallback sur username (case-sensitive) pour anciens users sans usernameLower
        if results.count < limit {
            let exactResults = try await queryUsers(field: "username", query: trimmed, limit: limit)
            appendUnique(exactResults)
        }
        
        if results.count < limit {
            let capitalized = trimmed.capitalized
            if capitalized != trimmed {
                let capResults = try await queryUsers(field: "username", query: capitalized, limit: limit)
                appendUnique(capResults)
            }
        }
        
        return Array(results.prefix(limit))
    }
    
    private func queryUsers(field: String, query: String, limit: Int) async throws -> [User] {
        let snapshot = try await db.collection("users")
            .order(by: field)
            .start(at: [query])
            .end(at: [query + "\u{f8ff}"])
            .limit(to: limit)
            .getDocuments()
        
        return try snapshot.documents.compactMap { document in
            let data = document.data()
            return try decodeUser(from: data)
        }
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
            "imageURL": wine.imageURL as Any,
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
            "rating": wine.rating as Any,
            "imageURL": wine.imageURL as Any
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
        
        let followingList = data["following"] as? [String] ?? []
        let followersList = data["followers"] as? [String] ?? []
        let followingCount = data["followingCount"] as? Int ?? followingList.count
        let followersCount = data["followersCount"] as? Int ?? followersList.count
        
        return User(
            id: id,
            username: username,
            email: email,
            profileImageURL: data["profileImageURL"] as? String,
            winesTasted: data["winesTasted"] as? [String] ?? [],
            wishlist: data["wishlist"] as? [String] ?? [],
            following: followingList,
            followers: followersList,
            followingCount: followingCount,
            followersCount: followersCount,
            privacyLevel: PrivacyLevel(rawValue: data["privacyLevel"] as? String ?? "public") ?? .public
        )
    }

    // MARK: - Follow System
    
    func followUser(followerId: String, followeeId: String) async throws -> Bool {
        guard followerId != followeeId else { return false }
        
        let followingRef = db.collection("users").document(followerId)
            .collection("following").document(followeeId)
        let followersRef = db.collection("users").document(followeeId)
            .collection("followers").document(followerId)
        let result = try await db.runTransaction { transaction, _ in
            let followingSnap: DocumentSnapshot
            do {
                followingSnap = try transaction.getDocument(followingRef)
            } catch {
                return false
            }
            
            if followingSnap.exists {
                return false
            }
            
            let data: [String: Any] = [
                "id": followeeId,
                "createdAt": FieldValue.serverTimestamp()
            ]
            let reverseData: [String: Any] = [
                "id": followerId,
                "createdAt": FieldValue.serverTimestamp()
            ]
            
            transaction.setData(data, forDocument: followingRef)
            transaction.setData(reverseData, forDocument: followersRef)
            
            return true
        }
        return (result as? Bool) ?? false
    }
    
    func unfollowUser(followerId: String, followeeId: String) async throws -> Bool {
        guard followerId != followeeId else { return false }
        
        let followingRef = db.collection("users").document(followerId)
            .collection("following").document(followeeId)
        let followersRef = db.collection("users").document(followeeId)
            .collection("followers").document(followerId)
        let result = try await db.runTransaction { transaction, _ in
            let followingSnap: DocumentSnapshot
            do {
                followingSnap = try transaction.getDocument(followingRef)
            } catch {
                return false
            }
            
            if !followingSnap.exists {
                return false
            }
            
            transaction.deleteDocument(followingRef)
            transaction.deleteDocument(followersRef)
            
            return true
        }
        return (result as? Bool) ?? false
    }
    
    func isFollowing(followerId: String, followeeId: String) async throws -> Bool {
        guard followerId != followeeId else { return false }
        let doc = try await db.collection("users").document(followerId)
            .collection("following").document(followeeId).getDocument()
        return doc.exists
    }
    
    func getFollowingIds(userId: String) async throws -> [String] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("following").getDocuments()
        return snapshot.documents.map { $0.documentID }
    }
    
    func getFollowerIds(userId: String) async throws -> [String] {
        let snapshot = try await db.collection("users").document(userId)
            .collection("followers").getDocuments()
        return snapshot.documents.map { $0.documentID }
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
            imageURL: data["imageURL"] as? String,
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
