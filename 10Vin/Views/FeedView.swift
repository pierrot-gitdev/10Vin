//
//  FeedView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel: WineViewModel
    @EnvironmentObject var authService: FirebaseAuthService
    @State private var showFilters = false
    
    var body: some View {
        NavigationView {
            ZStack {
                WineTheme.cream
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding()
                        } else if viewModel.feedPosts.isEmpty {
                            EmptyFeedView()
                        } else {
                            ForEach(viewModel.feedPosts) { post in
                                if let wine = viewModel.wines.first(where: { $0.id == post.wineId }) {
                                    FeedPostCard(post: post, wine: wine, viewModel: viewModel)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
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
    FeedView(viewModel: WineViewModel())
}
