//
//  FollowersFollowingListView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import SwiftUI

enum FollowListType {
    case followers
    case following
    
    var title: String {
        switch self {
        case .followers:
            return "profile.followers".localized
        case .following:
            return "profile.following".localized
        }
    }
}

struct FollowersFollowingListView: View {
    let type: FollowListType
    let userIds: [String]
    @ObservedObject var viewModel: WineViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var users: [User] = []
    
    var body: some View {
        NavigationView {
            List {
                if users.isEmpty {
                    Text("common.loading".localized)
                        .foregroundColor(WineTheme.darkGray)
                } else {
                    ForEach(users) { user in
                        HStack(spacing: 12) {
                            NavigationLink {
                                UserProfileView(userId: user.id, viewModel: viewModel)
                            } label: {
                                HStack(spacing: 12) {
                                    if let imageURL = user.profileImageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                                        AsyncImageView(url: url, size: 40, fallbackInitial: user.username.first.map { String($0) })
                                    } else {
                                        Circle()
                                            .fill(WineTheme.wineGradient)
                                            .frame(width: 40, height: 40)
                                            .overlay(
                                                Text(String(user.username.prefix(1)).uppercased())
                                                    .font(.headline)
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    
                                    Text(user.username)
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            if user.id != viewModel.currentUser?.id {
                                let isFollowing = viewModel.followingIds.contains(user.id)
                                Button(action: {
                                    Task {
                                        if isFollowing {
                                            try? await viewModel.unfollowUser(user.id)
                                        } else {
                                            try? await viewModel.followUser(user.id)
                                        }
                                    }
                                }) {
                                    Text(isFollowing ? "feed.following".localized : "feed.follow".localized)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(isFollowing ? WineTheme.burgundy.opacity(0.15) : WineTheme.burgundy)
                                        .foregroundColor(isFollowing ? WineTheme.burgundy : .white)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(WineTheme.burgundy)
                    }
                }
            }
        }
        .task {
            users = await viewModel.getUsers(by: userIds)
        }
    }
}

