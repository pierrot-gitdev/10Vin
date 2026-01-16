//
//  MainTabView.swift
//  10Vin
//
//  Created by Pierre ROBERT on 16/01/2026.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = WineViewModel()
    @State private var showAddWine = false
    @State private var selectedTab = 0
    
    var body: some View {
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
    }
}

#Preview {
    MainTabView()
}
