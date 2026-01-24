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
            FeedView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("tab.feed".localized, systemImage: "wineglass.fill")
                }
                .tag(0)
            
            // Onglet Add - ouvre directement le formulaire
            Color.clear
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
        .onChange(of: selectedTab) { newTab in
            // Ouvrir directement le formulaire quand l'onglet Add est sélectionné
            if newTab == 1 {
                showAddWine = true
            }
        }
        .sheet(isPresented: $showAddWine) {
            AddWineView(viewModel: viewModel, selectedTab: $selectedTab)
        }
        .onChange(of: showAddWine) { isPresented in
            // Revenir au feed quand le formulaire est fermé
            if !isPresented && selectedTab == 1 {
                selectedTab = 0
            }
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
