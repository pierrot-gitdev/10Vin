//
//  FeedView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: WineViewModel
    @Binding var selectedTab: Int
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var showFilters = false
    @State private var selectedUserId: String? = nil
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isSearchingUsers = false
    @State private var searchTask: Task<Void, Never>?
    @State private var searchCache: [String: [User]] = [:]
    @State private var followLoadingIds: Set<String> = []
    @State private var showFollowError = false
    @State private var followErrorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        SearchBar(text: $searchText)
                            .padding(.horizontal)
                        
                        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 {
                            SearchResultsList(
                                users: searchResults,
                                isLoading: isSearchingUsers,
                                onUserTap: handleUserTap(_:),
                                onFollowToggle: handleFollowToggle(_:),
                                currentUserId: viewModel.currentUser?.id,
                                followingIds: viewModel.followingIds,
                                loadingIds: followLoadingIds
                            )
                            .padding(.horizontal)
                        } else {
                            if viewModel.feedPosts.isEmpty && !viewModel.isLoading {
                                EmptyFeedView()
                            } else {
                                ForEach(viewModel.feedPosts) { post in
                                    if let wine = viewModel.wines.first(where: { $0.id == post.wineId }) {
                                        FeedPostCard(post: post, wine: wine, viewModel: viewModel) { tappedUserId in
                                            handleUserTap(tappedUserId)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(
                    NavigationLink(
                        destination: Group {
                            if let userId = selectedUserId {
                                UserProfileView(userId: userId, viewModel: viewModel)
                            } else {
                                EmptyView()
                            }
                        },
                        isActive: Binding(
                            get: { selectedUserId != nil },
                            set: { isActive in
                                if !isActive { selectedUserId = nil }
                            }
                        )
                    ) {
                        EmptyView()
                    }
                )
            }
            .navigationTitle("feed.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showFilters = true
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundColor(WineTheme.burgundy)
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: viewModel)
            }
            .onAppear {
                // Recharger les données quand la vue apparaît
                if let userId = authService.currentUser?.id {
                    Task {
                        await viewModel.loadData(userId: userId)
                    }
                }
            }
            .onChange(of: searchText) { newValue in
                handleSearchChange(newValue)
            }
            .alert("common.error".localized, isPresented: $showFollowError) {
                Button("common.ok".localized, role: .cancel) { }
            } message: {
                Text(followErrorMessage)
            }
        }
    }
}

private extension FeedView {
    func handleUserTap(_ userId: String) {
        if userId == viewModel.currentUser?.id {
            selectedTab = 2
        } else {
            selectedUserId = userId
        }
    }
    
    func handleFollowToggle(_ userId: String) {
        Task {
            if followLoadingIds.contains(userId) { return }
            await MainActor.run {
                followLoadingIds.insert(userId)
            }
            do {
                if viewModel.followingIds.contains(userId) {
                    try await viewModel.unfollowUser(userId)
                } else {
                    try await viewModel.followUser(userId)
                }
            } catch {
                await MainActor.run {
                    followErrorMessage = error.localizedDescription
                    showFollowError = true
                }
            }
            await MainActor.run {
                followLoadingIds.remove(userId)
            }
        }
    }
    
    func handleSearchChange(_ value: String) {
        let query = value.trimmingCharacters(in: .whitespacesAndNewlines)
        searchTask?.cancel()
        
        guard query.count >= 3 else {
            isSearchingUsers = false
            searchResults = []
            return
        }
        
        let normalized = query.lowercased()
        if let cached = searchCache[normalized] {
            searchResults = cached
            isSearchingUsers = false
            return
        }
        
        isSearchingUsers = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            if Task.isCancelled { return }
            let results = await viewModel.searchUsers(query: normalized, limit: 20)
            if Task.isCancelled { return }
            let filtered = results.filter { $0.id != viewModel.currentUser?.id }
            await MainActor.run {
                searchCache[normalized] = filtered
                searchResults = filtered
                isSearchingUsers = false
            }
        }
    }
}

private struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("feed.search.placeholder".localized, text: $text)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

private struct SearchResultsList: View {
    let users: [User]
    let isLoading: Bool
    let onUserTap: (String) -> Void
    let onFollowToggle: (String) -> Void
    let currentUserId: String?
    let followingIds: [String]
    let loadingIds: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if isLoading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("common.loading".localized)
                        .foregroundColor(WineTheme.darkGray)
                }
                .padding(.vertical, 8)
            } else if users.isEmpty {
                Text("feed.search.noResults".localized)
                    .foregroundColor(WineTheme.darkGray)
                    .padding(.vertical, 8)
            } else {
                ForEach(users) { user in
                    HStack(spacing: 12) {
                        Button(action: { onUserTap(user.id) }) {
                            HStack(spacing: 12) {
                                if let imageURL = user.profileImageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                                    AsyncImageView(url: url, size: 36, fallbackInitial: user.username.first.map { String($0) })
                                } else {
                                    Circle()
                                        .fill(WineTheme.wineGradient)
                                        .frame(width: 36, height: 36)
                                        .overlay(
                                            Text(String(user.username.prefix(1)).uppercased())
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        )
                                }
                                Text(user.username)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Spacer()
                        
                        if user.id != currentUserId {
                            let isFollowing = followingIds.contains(user.id)
                            let isLoading = loadingIds.contains(user.id)
                            Button(action: { onFollowToggle(user.id) }) {
                                HStack(spacing: 6) {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle())
                                    }
                                    Text(isFollowing ? "feed.following".localized : "feed.follow".localized)
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(isFollowing ? WineTheme.burgundy.opacity(0.15) : WineTheme.burgundy)
                                .foregroundColor(isFollowing ? WineTheme.burgundy : .white)
                                .cornerRadius(16)
                            }
                            .disabled(isLoading)
                        }
                    }
                    .padding(.vertical, 6)
                    
                    Divider()
                }
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wineglass")
                .font(.system(size: 60))
                .foregroundColor(WineTheme.burgundy.opacity(0.5))
            
            Text("feed.noPosts".localized)
                .font(.headline)
                .foregroundColor(WineTheme.darkGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#Preview {
    FeedView(viewModel: WineViewModel(), selectedTab: .constant(0))
}
