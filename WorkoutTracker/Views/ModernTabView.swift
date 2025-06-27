//
//  ModernTabView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernTabView: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            ModernDashboardView(viewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: viewModel.selectedTab == 0 ? "house.fill" : "house")
                        Text("Home")
                    }
                }
                .tag(0)
            
            WorkoutView(viewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: viewModel.selectedTab == 1 ? "figure.run" : "figure.walk")
                        Text("Workout")
                    }
                }
                .tag(1)
            
            PokemonListView(viewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: viewModel.selectedTab == 2 ? "sparkles" : "sparkle")
                        Text("Pokemon")
                    }
                }
                .tag(2)
            
            ProfileView(viewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: viewModel.selectedTab == 3 ? "person.fill" : "person")
                        Text("Profile")
                    }
                }
                .tag(3)
        }
        .tint(Theme.Colors.accent)
    }
}

#Preview {
    ModernTabView(viewModel: AppViewModel())
}