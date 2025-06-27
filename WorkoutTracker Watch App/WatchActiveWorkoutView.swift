//
//  WatchActiveWorkoutView.swift
//  WorkoutTracker Watch App
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct WatchActiveWorkoutView: View {
    @EnvironmentObject var workoutManager: WatchWorkoutManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Workout Duration
            Text(formatDuration(workoutManager.workoutDuration))
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Workout Stats
            HStack(spacing: 20) {
                VStack {
                    Text("\(Int(workoutManager.heartRate))")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("♥️ BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(Int(workoutManager.caloriesBurned))")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("🔥 Cal")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Control Buttons
            HStack(spacing: 20) {
                Button {
                    workoutManager.pauseWorkout()
                } label: {
                    Image(systemName: "pause.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
                
                Button {
                    workoutManager.endWorkout()
                } label: {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.red)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // XP Preview
            if let companion = workoutManager.activeCompanion {
                VStack(spacing: 4) {
                    Text("Your companion will gain:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(estimatedXP) XP")
                        .font(.headline)
                        .foregroundColor(companion.type.color)
                }
                .padding(.top, 8)
            }
        }
        .padding()
    }
    
    private var estimatedXP: Int {
        // Estimate XP based on workout duration (rough calculation)
        let baseXP = 10
        let durationBonus = Int(workoutManager.workoutDuration / 60) * 5 // 5 XP per minute
        return baseXP + durationBonus
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}