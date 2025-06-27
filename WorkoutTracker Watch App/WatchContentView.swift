//
//  WatchContentView.swift
//  WorkoutTracker Watch App
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct WatchContentView: View {
    @StateObject private var workoutManager = WatchWorkoutManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Companion Display
                if let activeCompanion = workoutManager.activeCompanion {
                    WatchCompanionCardView(companion: activeCompanion)
                }
                
                // Workout Controls
                if workoutManager.isWorkoutActive {
                    WatchActiveWorkoutView()
                        .environmentObject(workoutManager)
                } else {
                    WatchWorkoutSelectionView()
                        .environmentObject(workoutManager)
                }
            }
            .navigationTitle("CompanionFit")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            workoutManager.loadUserData()
        }
    }
}