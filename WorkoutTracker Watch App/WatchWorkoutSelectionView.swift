//
//  WatchWorkoutSelectionView.swift
//  WorkoutTracker Watch App
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI
import HealthKit

struct WatchWorkoutSelectionView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    
    private let workoutTypes: [(String, HKWorkoutActivityType, String)] = [
        ("Strength", .traditionalStrengthTraining, "💪"),
        ("Cardio", .other, "🏃‍♂️"),
        ("Yoga", .yoga, "🧘‍♀️"),
        ("Sports", .other, "⚽️")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(workoutTypes, id: \.0) { name, type, emoji in
                    Button {
                        workoutManager.startWorkout(type: type)
                    } label: {
                        HStack {
                            Text(emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(name)
                                    .font(.headline)
                                Text("Start \(name) workout")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "play.fill")
                                .foregroundColor(.green)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
}