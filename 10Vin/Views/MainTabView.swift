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
    
    var body: some View {
        TabView {
            FeedView(viewModel: viewModel)
                .tabItem {
                    Label("tab.feed".localized, systemImage: "wineglass.fill")
                }
            
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
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    Label("tab.profile".localized, systemImage: "person.fill")
                }
        }
        .accentColor(WineTheme.burgundy)
        .sheet(isPresented: $showAddWine) {
            AddWineView(viewModel: viewModel)
        }
    }
}

#Preview {
    MainTabView()
}
