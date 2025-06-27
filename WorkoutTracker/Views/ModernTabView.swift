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
            
            ModernWorkoutView(viewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: viewModel.selectedTab == 1 ? "figure.run" : "figure.walk")
                        Text("Workout")
                    }
                }
                .tag(1)
            
            CompanionListView(viewModel: viewModel)
                .tabItem {
                    VStack {
                        Image(systemName: viewModel.selectedTab == 2 ? "sparkles" : "sparkles")
                        Text("Companions")
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
        .tint(Color.blue)
    }
}

#Preview {
    ModernTabView(viewModel: AppViewModel())
}