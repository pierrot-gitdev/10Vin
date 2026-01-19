//
//  MainTabView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authService: FirebaseAuthService
    @StateObject private var viewModel = WineViewModel()
    @State private var showAddWine = false
    @State private var selectedTab = 0
    @State private var isInitialLoading = true
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
            FeedView(viewModel: viewModel)
                .tabItem {
                    Label("tab.feed".localized, systemImage: "wineglass.fill")
                }
                .tag(0)
            
            Button(action: {
                showAddWine = true
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(WineTheme.burgundy)
                    Text("tab.add".localized)
                        .font(.caption)
                        .foregroundColor(WineTheme.burgundy)
                }
            }
            .tabItem {
                Label("tab.add".localized, systemImage: "plus.circle")
            }
            .tag(1)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("tab.profile".localized, systemImage: "person.fill")
                }
                .tag(2)
        }
        .tint(Color.accentColor) // Utilise l'AccentColor défini dans Assets
        .sheet(isPresented: $showAddWine) {
            AddWineView(viewModel: viewModel, selectedTab: $selectedTab)
        }
        .onAppear {
            // Synchroniser le currentUser avec authService
            viewModel.currentUser = authService.currentUser
            
            // Charger les données depuis Firebase
            if let userId = authService.currentUser?.id {
                Task {
                    await viewModel.loadData(userId: userId)
                }
            }
        }
        .onChange(of: authService.currentUser) { newUser in
            viewModel.currentUser = newUser
            if let userId = newUser?.id {
                Task {
                    await viewModel.loadData(userId: userId)
                }
            }
        }
        .onChange(of: viewModel.isLoading) { isLoading in
            // Masquer le loading initial une fois le chargement terminé
            if !isLoading && isInitialLoading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isInitialLoading = false
                    }
                }
            }
        }
        
        // Overlay de chargement initial
        if isInitialLoading || viewModel.isLoading {
            WineLoadingOverlay(isLoading: .constant(true))
        }
        }
    }
}

#Preview {
    MainTabView()
}
