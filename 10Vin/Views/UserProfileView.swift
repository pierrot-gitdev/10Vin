//
//  UserProfileView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import SwiftUI

struct UserProfileView: View {
    let userId: String
    @ObservedObject var viewModel: WineViewModel
    @State private var user: User?
    @State private var isFollowActionLoading = false
    @State private var showFollowError = false
    @State private var followErrorMessage = ""
    
    private var isCurrentUser: Bool {
        viewModel.currentUser?.id == userId
    }

    private var isFollowing: Bool {
        viewModel.followingIds.contains(userId)
    }
    
    var body: some View {
        ZStack {
            WineTheme.cream
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    if let loadedUser = user {
                        VStack(spacing: 12) {
                            if let imageURL = loadedUser.profileImageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                                AsyncImageView(url: url, size: 90, fallbackInitial: loadedUser.username.first.map { String($0) })
                            } else {
                                Circle()
                                    .fill(WineTheme.wineGradient)
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Text(String(loadedUser.username.prefix(1)).uppercased())
                                            .font(.system(size: 32, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            Text(loadedUser.username)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.black)
                            
                            if !isCurrentUser {
                                Button(action: {
                                    Task {
                                        guard !isFollowActionLoading else { return }
                                        await MainActor.run {
                                            isFollowActionLoading = true
                                        }
                                        do {
                                            if isFollowing {
                                                try await viewModel.unfollowUser(userId)
                                            } else {
                                                try await viewModel.followUser(userId)
                                            }
                                            if let refreshed = await viewModel.getUser(by: userId) {
                                                await MainActor.run {
                                                    user = refreshed
                                                }
                                            }
                                        } catch {
                                            await MainActor.run {
                                                followErrorMessage = error.localizedDescription
                                                showFollowError = true
                                            }
                                        }
                                        await MainActor.run {
                                            isFollowActionLoading = false
                                        }
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        if isFollowActionLoading {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle())
                                        }
                                        Text(isFollowing ? "feed.following".localized : "feed.follow".localized)
                                    }
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isFollowing ? WineTheme.burgundy.opacity(0.15) : WineTheme.burgundy)
                                    .foregroundColor(isFollowing ? WineTheme.burgundy : .white)
                                    .cornerRadius(20)
                                }
                                .disabled(isFollowActionLoading)
                            }
                            
                            HStack(spacing: 0) {
                                ProfileStatView(
                                    count: max(loadedUser.followingCount, loadedUser.following.count),
                                    label: "profile.following".localized
                                )
                                Rectangle()
                                    .fill(WineTheme.darkGray.opacity(0.3))
                                    .frame(width: 1, height: 32)
                                ProfileStatView(
                                    count: max(loadedUser.followersCount, loadedUser.followers.count),
                                    label: "profile.followers".localized
                                )
                                Rectangle()
                                    .fill(WineTheme.darkGray.opacity(0.3))
                                    .frame(width: 1, height: 32)
                                ProfileStatView(
                                    count: loadedUser.winesTasted.count,
                                    label: "profile.10vino".localized
                                )
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
                        )
                        .padding(.horizontal, 16)
                    } else {
                        Text("common.loading".localized)
                            .foregroundColor(WineTheme.darkGray)
                            .padding(.top, 40)
                    }
                }
                .padding(.top, 16)
            }
        }
        .navigationTitle("profile.title".localized)
        .navigationBarTitleDisplayMode(.inline)
        .alert("common.error".localized, isPresented: $showFollowError) {
            Button("common.ok".localized, role: .cancel) { }
        } message: {
            Text(followErrorMessage)
        }
        .task {
            user = await viewModel.getUser(by: userId)
        }
    }
}

