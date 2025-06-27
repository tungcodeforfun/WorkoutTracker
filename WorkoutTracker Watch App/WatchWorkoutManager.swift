//
//  WatchWorkoutManager.swift
//  WorkoutTracker Watch App
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation
import HealthKit
import WatchKit
import SwiftUI

@MainActor
class WatchWorkoutManager: NSObject, ObservableObject {
    @Published var isWorkoutActive = false
    @Published var currentWorkout: Workout?
    @Published var activeCompanion: Companion?
    @Published var workoutDuration: TimeInterval = 0
    @Published var heartRate: Double = 0
    @Published var caloriesBurned: Double = 0
    
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var workoutTimer: Timer?
    private var startTime: Date?
    
    override init() {
        super.init()
        requestHealthKitPermissions()
    }
    
    // MARK: - HealthKit Setup
    
    private func requestHealthKitPermissions() {
        let typesToShare: Set = [
            HKQuantityType.workoutType()
        ]
        
        let typesToRead: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if !success {
                print("HealthKit authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // MARK: - Data Loading
    
    func loadUserData() {
        // Load user data from shared container or sync with iPhone
        guard let userData = UserDefaults.standard.data(forKey: "currentUser") else {
            return
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            activeCompanion = user.activeCompanion
        } catch {
            print("Failed to load user data on Watch: \(error)")
        }
    }
    
    // MARK: - Workout Control
    
    func startWorkout(type: HKWorkoutActivityType) {
        guard !isWorkoutActive else { return }
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = type
        configuration.locationType = .indoor
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = workoutSession?.associatedWorkoutBuilder()
            builder?.delegate = self
            
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
            
            workoutSession?.delegate = self
            
            let startDate = Date()
            workoutSession?.startActivity(with: startDate)
            builder?.beginCollection(withStart: startDate) { success, error in
                if success {
                    DispatchQueue.main.async {
                        self.isWorkoutActive = true
                        self.startTime = startDate
                        self.currentWorkout = Workout(date: startDate)
                        self.startTimer()
                        
                        // Provide haptic feedback
                        WKInterfaceDevice.current().play(.start)
                    }
                }
            }
        } catch {
            print("Failed to start workout: \(error)")
        }
    }
    
    func pauseWorkout() {
        workoutSession?.pause()
        stopTimer()
        WKInterfaceDevice.current().play(.stop)
    }
    
    func resumeWorkout() {
        workoutSession?.resume()
        startTimer()
        WKInterfaceDevice.current().play(.start)
    }
    
    func endWorkout() {
        workoutSession?.end()
        stopTimer()
        
        // Save workout data
        if let workout = currentWorkout, let startTime = startTime {
            workout.totalDuration = Int(workoutDuration)
            // Add the workout to companion XP
            activeCompanion?.gainExperience(workout.totalExperience)
            saveWorkout(workout)
        }
        
        isWorkoutActive = false
        currentWorkout = nil
        workoutDuration = 0
        heartRate = 0
        caloriesBurned = 0
        
        WKInterfaceDevice.current().play(.success)
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.workoutDuration += 1
        }
    }
    
    private func stopTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }
    
    // MARK: - Data Persistence
    
    private func saveWorkout(_ workout: Workout) {
        // Save to UserDefaults for now - in a real app you'd sync with iPhone
        do {
            let encoded = try JSONEncoder().encode(workout)
            UserDefaults.standard.set(encoded, forKey: "lastWatchWorkout")
        } catch {
            print("Failed to save workout: \(error)")
        }
    }
}

// MARK: - HKWorkoutSessionDelegate

extension WatchWorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            switch toState {
            case .running:
                self.isWorkoutActive = true
            case .paused:
                self.isWorkoutActive = false
            case .ended:
                self.isWorkoutActive = false
            default:
                break
            }
        }
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session failed: \(error)")
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate

extension WatchWorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            
            if quantityType == HKQuantityType.quantityType(forIdentifier: .heartRate) {
                if let heartRateData = workoutBuilder.allStatistics[quantityType]?.mostRecentQuantity() {
                    DispatchQueue.main.async {
                        self.heartRate = heartRateData.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    }
                }
            }
            
            if quantityType == HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
                if let caloriesData = workoutBuilder.allStatistics[quantityType]?.sumQuantity() {
                    DispatchQueue.main.async {
                        self.caloriesBurned = caloriesData.doubleValue(for: .kilocalorie())
                    }
                }
            }
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Handle workout events
    }
}