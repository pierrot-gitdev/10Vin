//
//  ShareWineView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 24/01/2026.
//

import SwiftUI

struct ShareWineView: View {
    @ObservedObject var viewModel: WineViewModel
    let wine: Wine
    let onUserTap: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var users: [User] = []
    @State private var sendingIds: Set<String> = []
    @State private var sentIds: Set<String> = []
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                if users.isEmpty {
                    Text("share.empty".localized)
                        .foregroundColor(WineTheme.darkGray)
                        .padding(.top, 24)
                    Spacer()
                } else {
                    List {
                        ForEach(users) { user in
                            HStack(spacing: 12) {
                                Button(action: { onUserTap(user.id) }) {
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
                                
                                let isSending = sendingIds.contains(user.id)
                                let isSent = sentIds.contains(user.id)
                                
                                Button(action: {
                                    Task {
                                        if isSending || isSent { return }
                                        await MainActor.run { sendingIds.insert(user.id) }
                                        do {
                                            try await viewModel.recommendWine(to: user.id, wineId: wine.id)
                                            await MainActor.run {
                                                sentIds.insert(user.id)
                                            }
                                        } catch {
                                            await MainActor.run {
                                                errorMessage = error.localizedDescription
                                                showError = true
                                            }
                                        }
                                        await MainActor.run { sendingIds.remove(user.id) }
                                    }
                                }) {
                                    HStack(spacing: 6) {
                                        if isSending {
                                            ProgressView()
                                        }
                                        Text(isSent ? "share.sent".localized : "share.send".localized)
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(isSent ? WineTheme.burgundy.opacity(0.15) : WineTheme.burgundy)
                                    .foregroundColor(isSent ? WineTheme.burgundy : .white)
                                    .cornerRadius(16)
                                }
                                .disabled(isSending || isSent)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("share.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(WineTheme.burgundy)
                    }
                }
            }
            .alert("common.error".localized, isPresented: $showError) {
                Button("common.ok".localized, role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .task {
                users = await viewModel.getUsers(by: viewModel.followingIds)
            }
        }
    }
}

