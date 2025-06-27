//
//  ContentView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some View {
        if viewModel.currentUser != nil {
            if viewModel.showingCompanionSelection {
                ModernCompanionSelectionView(viewModel: viewModel)
                    .buttonStyle(PlainButtonStyle())
            } else {
                ModernTabView(viewModel: viewModel)
                    .buttonStyle(PlainButtonStyle())
            }
        } else {
            ModernOnboardingView(viewModel: viewModel)
                .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    ContentView()
}
