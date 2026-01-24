//
//  User.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var username: String
    var email: String
    var profileImageURL: String?
    var winesTasted: [String] // IDs des vins goûtés
    var wishlist: [String] // IDs des vins en wish-list
    var following: [String] // IDs des utilisateurs suivis
    var followers: [String] // IDs des followers
    var followingCount: Int
    var followersCount: Int
    var privacyLevel: PrivacyLevel
    
    init(
        id: String,
        username: String,
        email: String,
        profileImageURL: String? = nil,
        winesTasted: [String] = [],
        wishlist: [String] = [],
        following: [String] = [],
        followers: [String] = [],
        followingCount: Int = 0,
        followersCount: Int = 0,
        privacyLevel: PrivacyLevel = .public
    ) {
        self.id = id
        self.username = username
        self.email = email
        self.profileImageURL = profileImageURL
        self.winesTasted = winesTasted
        self.wishlist = wishlist
        self.following = following
        self.followers = followers
        self.followingCount = followingCount
        self.followersCount = followersCount
        self.privacyLevel = privacyLevel
    }
}
