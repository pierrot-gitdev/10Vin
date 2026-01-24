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
    @State private var showUserSearch = false
    @State private var shareWine: Wine?
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.feedPosts.isEmpty && !viewModel.isLoading {
                            EmptyFeedView()
                        } else {
                            ForEach(viewModel.feedPosts) { post in
                                if let wine = viewModel.wines.first(where: { $0.id == post.wineId }) {
                                    FeedPostCard(
                                        post: post,
                                        wine: wine,
                                        viewModel: viewModel,
                                        onProfileTap: { tappedUserId in
                                            handleUserTap(tappedUserId)
                                        },
                                        onShare: { selectedWine in
                                            shareWine = selectedWine
                                        }
                                    )
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
                    HStack(spacing: 16) {
                        Button(action: { showUserSearch = true }) {
                            Image("search")
                                .renderingMode(.original)
                        }
                        Button(action: { showFilters = true }) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(WineTheme.burgundy)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: viewModel)
            }
            .sheet(isPresented: $showUserSearch) {
                SearchUsersView(
                    viewModel: viewModel,
                    onUserTap: handleUserTap(_:)
                )
            }
            .sheet(item: $shareWine) { wine in
                ShareWineView(
                    viewModel: viewModel,
                    wine: wine,
                    onUserTap: handleUserTap(_:)
                )
            }
            .onAppear {
                // Recharger les données quand la vue apparaît
                if let userId = authService.currentUser?.id {
                    Task {
                        await viewModel.loadData(userId: userId)
                    }
                }
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
