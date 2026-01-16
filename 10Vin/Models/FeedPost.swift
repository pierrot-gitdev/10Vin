//
//  FeedPost.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation

struct FeedPost: Identifiable, Codable {
    let id: String
    let wineId: String
    let userId: String
    let username: String
    let userProfileImageURL: String?
    let postedDate: Date
    var likes: [String] // IDs des utilisateurs qui ont liké
    var comments: [Comment]
    
    init(
        id: String = UUID().uuidString,
        wineId: String,
        userId: String,
        username: String,
        userProfileImageURL: String? = nil,
        postedDate: Date = Date(),
        likes: [String] = [],
        comments: [Comment] = []
    ) {
        self.id = id
        self.wineId = wineId
        self.userId = userId
        self.username = username
        self.userProfileImageURL = userProfileImageURL
        self.postedDate = postedDate
        self.likes = likes
        self.comments = comments
    }
}

struct Comment: Identifiable, Codable {
    let id: String
    let userId: String
    let username: String
    let text: String
    let date: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        username: String,
        text: String,
        date: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.text = text
        self.date = date
    }
}
