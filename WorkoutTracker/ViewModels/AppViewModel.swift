//
//  AppViewModel.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var selectedTab = 0
    @Published var showingCompanionSelection = false
    @Published var showingWorkoutCreation = false
    @Published var healthKitManager: HealthKitManager?
    @Published var healthKitEnabled = false
    
    init() {
        loadUser()
        setupHealthKit()
    }
    
    private func setupHealthKit() {
        // Skip HealthKit setup in testing environment or if not available
        guard !ProcessInfo.processInfo.environment.keys.contains("XCTestConfigurationFilePath") else {
            print("Skipping HealthKit setup in test environment")
            return
        }
        
        // Only create HealthKitManager in non-test environment
        healthKitManager = HealthKitManager()
        
        Task {
            do {
                if let manager = healthKitManager {
                    try await manager.requestHealthKitPermissions()
                    healthKitEnabled = manager.authorizationStatus == .sharingAuthorized
                }
            } catch {
                print("HealthKit setup failed: \(error)")
                healthKitEnabled = false
            }
        }
    }
    
    func createUser(username: String, trainerName: String) {
        let newUser = User(username: username, trainerName: trainerName)
        currentUser = newUser
        showingCompanionSelection = true
        saveUser()
    }
    
    func selectStarterCompanion(_ companion: Companion) {
        currentUser?.addCompanion(companion)
        showingCompanionSelection = false
        saveUser()
    }
    
    func completeWorkout(_ workout: Workout) {
        currentUser?.completeWorkout(workout)
        saveUser()
        
        // Sync to HealthKit if enabled
        if healthKitEnabled, let manager = healthKitManager {
            Task {
                do {
                    try await manager.saveWorkout(workout)
                } catch {
                    print("Failed to save workout to HealthKit: \(error)")
                }
            }
        }
    }
    
    func setActiveCompanion(_ companionId: UUID) {
        currentUser?.setActiveCompanion(companionId)
        saveUser()
    }
    
    func updateCompanionNickname(_ companionId: UUID, nickname: String) {
        currentUser?.updateCompanionNickname(companionId, nickname: nickname)
        saveUser()
    }
    
    
    private func loadUser() {
        // Skip loading user data in test environment to ensure clean state
        guard !ProcessInfo.processInfo.environment.keys.contains("XCTestConfigurationFilePath") else {
            return
        }
        
        guard let userData = UserDefaults.standard.data(forKey: "currentUser") else {
            return
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            currentUser = user
        } catch {
            print("Failed to decode user data: \(error)")
            UserDefaults.standard.removeObject(forKey: "currentUser")
        }
    }
    
    func resetUser() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func saveUser() {
        guard let user = currentUser else { return }
        
        do {
            let encoded = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        } catch {
            print("Failed to encode user data: \(error)")
        }
    }
}