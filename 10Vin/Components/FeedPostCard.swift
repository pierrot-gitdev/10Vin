//
//  FeedPostCard.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct FeedPostCard: View {
    let post: FeedPost
    let wine: Wine
    @ObservedObject var viewModel: WineViewModel
    @State private var showComments = false
    @State private var commentText = ""
    
    var isLiked: Bool {
        guard let userId = viewModel.currentUser?.id else { return false }
        return post.likes.contains(userId)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header utilisateur
            HStack(spacing: 12) {
                // Photo de profil avec chargement depuis URL
                Group {
                    if let imageURL = post.userProfileImageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
                        AsyncImageView(url: url, size: 40, fallbackInitial: post.username.first.map { String($0) })
                    } else {
                        Circle()
                            .fill(WineTheme.wineGradient)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(String(post.username.prefix(1)).uppercased())
                                    .font(.headline)
                                    .foregroundColor(.white)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline)
                        .foregroundColor(WineTheme.burgundy)
                    Text(post.postedDate.relativeTimeString)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            
            // Carte du vin
            WineCard(wine: wine, showFullDetails: true)
                .padding(.horizontal)
            
            // Actions (like, comment)
            HStack(spacing: 20) {
                Button(action: {
                    Task {
                        do {
                            try await viewModel.likePost(post.id)
                        } catch {
                            print("Error liking post: \(error.localizedDescription)")
                            // Erreur silencieuse lors du like
                        }
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : WineTheme.darkGray)
                        Text("\(post.likes.count)")
                            .font(.subheadline)
                            .foregroundColor(WineTheme.darkGray)
                    }
                }
                
                Button(action: {
                    showComments.toggle()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(WineTheme.darkGray)
                        Text("\(post.comments.count)")
                            .font(.subheadline)
                            .foregroundColor(WineTheme.darkGray)
                    }
                }
                
                Spacer()
            }
            .padding()
            
            // Section commentaires
            if showComments {
                Divider()
                
                // Liste des commentaires
                if !post.comments.isEmpty {
                    ForEach(post.comments) { comment in
                        CommentRow(comment: comment)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                    }
                }
                
                // Champ d'ajout de commentaire
                HStack(spacing: 12) {
                    TextField("feed.addComment".localized, text: $commentText)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: {
                        if !commentText.isEmpty {
                            Task {
                                do {
                                    try await viewModel.addComment(commentText, to: post.id)
                                    commentText = ""
                                } catch {
                                    print("Error adding comment: \(error.localizedDescription)")
                                    // Erreur silencieuse lors de l'ajout de commentaire
                                }
                            }
                        }
                    }) {
                        Text("feed.postComment".localized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(WineTheme.burgundy)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(WineTheme.burgundy.opacity(0.3))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(comment.username.prefix(1)).uppercased())
                        .font(.caption)
                        .foregroundColor(WineTheme.burgundy)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(comment.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(WineTheme.burgundy)
                
                Text(comment.text)
                    .font(.subheadline)
                    .foregroundColor(WineTheme.darkGray)
                
                Text(comment.date.relativeTimeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

#Preview {
    let viewModel = WineViewModel()
    let wine = Wine(
        type: .red,
        grapeVariety: "Pinot Noir",
        domain: "Domaine de la Romanée-Conti",
        vintage: 2018,
        region: "Bourgogne",
        tastingNotes: "Un vin d'exception avec des arômes de cerise et d'épices.",
        rating: 9.5,
        userId: "user1"
    )
    let post = FeedPost(
        wineId: wine.id,
        userId: "user1",
        username: "WineLover",
        likes: ["user1"],
        comments: [
            Comment(userId: "user2", username: "Friend", text: "Superbe choix !")
        ]
    )
    
    return FeedPostCard(post: post, wine: wine, viewModel: viewModel)
        .padding()
}
