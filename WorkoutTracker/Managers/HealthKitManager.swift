//
//  HealthKitManager.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation
import HealthKit

@MainActor
class HealthKitManager: ObservableObject {
    
    private let healthStore = HKHealthStore()
    
    @Published var isHealthKitAvailable = false
    @Published var authorizationStatus: HKAuthorizationStatus = .notDetermined
    
    // MARK: - Health Data Types
    
    private let readTypes: Set<HKObjectType> = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKObjectType.quantityType(forIdentifier: .stepCount)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!
    ]
    
    private let writeTypes: Set<HKSampleType> = [
        HKObjectType.workoutType(),
        HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
    ]
    
    init() {
        checkHealthKitSupport()
    }
    
    // MARK: - Setup
    
    private func checkHealthKitSupport() {
        isHealthKitAvailable = HKHealthStore.isHealthDataAvailable()
    }
    
    func requestHealthKitPermissions() async throws {
        guard isHealthKitAvailable else {
            throw HealthKitError.notAvailable
        }
        
        try await healthStore.requestAuthorization(toShare: writeTypes, read: readTypes)
        
        // Check authorization status for workouts specifically
        authorizationStatus = healthStore.authorizationStatus(for: HKObjectType.workoutType())
    }
    
    // MARK: - Writing Data
    
    func saveWorkout(_ workout: Workout) async throws {
        guard authorizationStatus == .sharingAuthorized else {
            throw HealthKitError.notAuthorized
        }
        
        let activityType = mapWorkoutTypeToHealthKit(workout: workout)
        
        let hkWorkout = HKWorkout(
            activityType: activityType,
            start: workout.date,
            end: workout.date.addingTimeInterval(TimeInterval(workout.totalDuration)),
            duration: TimeInterval(workout.totalDuration),
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: Double(workout.totalExperience) * 0.1),
            totalDistance: workout.totalDistance > 0 ? HKQuantity(unit: .meter(), doubleValue: workout.totalDistance * 1000) : nil,
            metadata: [
                HKMetadataKeyWorkoutBrandName: "CompanionFit",
                "companion_used": workout.companionUsed?.uuidString ?? "",
                "total_experience": workout.totalExperience
            ]
        )
        
        try await healthStore.save(hkWorkout)
    }
    
    func getWorkoutEnergyBurned(_ workout: HKWorkout) async throws -> Double? {
        #if os(iOS)
        // Use the newer API for iOS 15+
        if #available(iOS 15.0, *) {
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            if let statistics = workout.statistics(for: energyType) {
                return statistics.sumQuantity()?.doubleValue(for: .kilocalorie())
            }
        } else {
            // Fallback to deprecated method for older iOS versions
            return workout.totalEnergyBurned?.doubleValue(for: .kilocalorie())
        }
        #else
        // For other platforms, use the deprecated method if available
        return workout.totalEnergyBurned?.doubleValue(for: .kilocalorie())
        #endif
        
        return nil
    }
    
    // MARK: - Reading Data
    
    func fetchRecentWorkouts(limit: Int = 10) async throws -> [HKWorkout] {
        let workoutType = HKObjectType.workoutType()
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(
            sampleType: workoutType,
            predicate: nil,
            limit: limit,
            sortDescriptors: [sortDescriptor]
        ) { _, samples, error in
            // This will be handled by the async wrapper
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let asyncQuery = HKSampleQuery(
                sampleType: workoutType,
                predicate: nil,
                limit: limit,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    let workouts = samples as? [HKWorkout] ?? []
                    continuation.resume(returning: workouts)
                }
            }
            
            healthStore.execute(asyncQuery)
        }
    }
    
    func fetchTodaysSteps() async throws -> Double {
        let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    continuation.resume(returning: steps)
                }
            }
            
            healthStore.execute(query)
        }
    }
    
    // MARK: - Helper Methods
    
    private func mapWorkoutTypeToHealthKit(workout: Workout) -> HKWorkoutActivityType {
        // Analyze the workout exercises to determine the best HealthKit activity type
        let exerciseTypes = workout.exercises.map { $0.type }
        
        if exerciseTypes.contains(.cardio) {
            return .other // Could be more specific based on exercise names
        } else if exerciseTypes.contains(.strength) {
            return .traditionalStrengthTraining
        } else if exerciseTypes.contains(.flexibility) {
            return .yoga
        } else if exerciseTypes.contains(.sports) {
            return .other
        } else {
            return .other
        }
    }
}

// MARK: - Extensions

extension Workout {
    var totalDistance: Double {
        return exercises.compactMap { $0.distance }.reduce(0, +)
    }
}

// MARK: - Errors

enum HealthKitError: LocalizedError {
    case notAvailable
    case notAuthorized
    case noData
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .notAuthorized:
            return "HealthKit access not authorized"
        case .noData:
            return "No health data available"
        }
    }
}