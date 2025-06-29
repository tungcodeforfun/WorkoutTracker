//
//  HealthKitSettingsView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI
import HealthKit

struct HealthKitSettingsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var todaysSteps: Double = 0
    @State private var recentWorkouts: [HKWorkout] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            List {
                Section("HealthKit Status") {
                    HStack {
                        Image(systemName: appViewModel.healthKitEnabled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(appViewModel.healthKitEnabled ? .green : .red)
                        
                        VStack(alignment: .leading) {
                            Text("HealthKit Integration")
                                .font(.headline)
                            if let manager = appViewModel.healthKitManager, !manager.isHealthKitAvailable {
                                Text("Not Available (Simulator)")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            } else {
                                Text(appViewModel.healthKitEnabled ? "Connected" : "Not Connected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if let manager = appViewModel.healthKitManager, manager.isHealthKitAvailable && !appViewModel.healthKitEnabled {
                            Button("Enable") {
                                Task {
                                    do {
                                        try await manager.requestHealthKitPermissions()
                                        appViewModel.healthKitEnabled = manager.authorizationStatus == .sharingAuthorized
                                    } catch {
                                        print("Failed to enable HealthKit: \(error)")
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                
                if let manager = appViewModel.healthKitManager, !manager.isHealthKitAvailable {
                    Section {
                        Label("HealthKit is not available in the iOS Simulator", systemImage: "info.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("To test HealthKit features, please run the app on a physical device.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else if appViewModel.healthKitEnabled {
                    Section("Today's Health Data") {
                        HStack {
                            Image(systemName: "figure.walk")
                                .foregroundColor(.blue)
                            Text("Steps")
                            Spacer()
                            Text("\(Int(todaysSteps))")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Workouts Synced")
                            Spacer()
                            Text("\(recentWorkouts.count)")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    Section("Recent HealthKit Workouts") {
                        if recentWorkouts.isEmpty {
                            Text("No recent workouts found")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(recentWorkouts, id: \.uuid) { workout in
                                if let manager = appViewModel.healthKitManager {
                                    WorkoutRowView(workout: workout, healthKitManager: manager)
                                }
                            }
                        }
                    }
                }
                
                Section("Information") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About HealthKit Integration")
                            .font(.headline)
                        
                        Text("When enabled, CompanionFit will sync your workouts to Apple Health, allowing you to track your fitness progress across all your apps.")
                        
                        Text("Your data remains private and is only stored on your device and in your personal iCloud Health data.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Health & Fitness")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .refreshable {
                await loadHealthData()
            }
            .task {
                await loadHealthData()
            }
        }
    }
    
    private func loadHealthData() async {
        guard appViewModel.healthKitEnabled else { return }
        
        isLoading = true
        
        do {
            if let manager = appViewModel.healthKitManager {
                // Load today's steps
                todaysSteps = try await manager.fetchTodaysSteps()
                
                // Load recent workouts
                recentWorkouts = try await manager.fetchRecentWorkouts(limit: 5)
            }
        } catch {
            print("Failed to load health data: \(error)")
        }
        
        isLoading = false
    }
}

// MARK: - Extensions

struct WorkoutRowView: View {
    let workout: HKWorkout
    let healthKitManager: HealthKitManager?
    @State private var calories: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.workoutActivityType.displayName)
                    .font(.headline)
                Spacer()
                Text(workout.startDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Duration: \(formatDuration(workout.duration))")
                Spacer()
                if let calories = calories {
                    Text("\(Int(calories)) cal")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
        .task {
            do {
                if let manager = healthKitManager {
                    calories = try await manager.getWorkoutEnergyBurned(workout)
                }
            } catch {
                print("Failed to get calories for workout: \(error)")
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

extension HKWorkoutActivityType {
    var displayName: String {
        switch self {
        case .traditionalStrengthTraining:
            return "Strength Training"
        case .running:
            return "Running"
        case .cycling:
            return "Cycling"
        case .yoga:
            return "Yoga"
        case .other:
            return "Other"
        default:
            return "Workout"
        }
    }
}