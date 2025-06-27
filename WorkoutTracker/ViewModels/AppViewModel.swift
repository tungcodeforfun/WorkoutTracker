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
    @Published var healthKitManager = HealthKitManager()
    @Published var healthKitEnabled = false
    
    init() {
        loadUser()
        setupHealthKit()
    }
    
    private func setupHealthKit() {
        Task {
            do {
                try await healthKitManager.requestHealthKitPermissions()
                healthKitEnabled = healthKitManager.authorizationStatus == .sharingAuthorized
            } catch {
                print("HealthKit setup failed: \(error)")
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
        if healthKitEnabled {
            Task {
                do {
                    try await healthKitManager.saveWorkout(workout)
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