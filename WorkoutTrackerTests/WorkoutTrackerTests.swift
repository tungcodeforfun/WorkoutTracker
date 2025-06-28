//
//  WorkoutTrackerTests.swift
//  WorkoutTrackerTests
//
//  Created by Tung Nguyen on 6/27/25.
//

import Testing
import Foundation
@testable import WorkoutTracker

/// Main test suite for WorkoutTracker app
/// This file contains integration tests and overall app functionality tests
struct WorkoutTrackerTests {
    
    // MARK: - App Integration Tests
    
    @Test func testAppModelsIntegration() async throws {
        // Given - Create a complete user scenario
        var user = User(username: "integration", trainerName: "Integration Tester")
        let companion = Companion(name: "IntegrationMon", type: .flame, evolutionLevel: 3, evolvedForm: "SuperMon")
        user.addCompanion(companion)
        
        // Verify companion is set as active (should be automatic since it's the first)
        #expect(user.activeCompanionId != nil)
        #expect(user.companions.count == 1)
        
        // Store the actual companion ID from the user's array
        let companionId = user.companions.first!.id
        #expect(user.activeCompanionId == companionId)
        
        // Create a comprehensive workout
        var workout = Workout()
        
        var exercise1 = Exercise(name: "Bench Press", type: .strength)
        exercise1.sets = 3
        exercise1.reps = 10
        exercise1.weight = 80.0
        
        var exercise2 = Exercise(name: "Running", type: .cardio)
        exercise2.duration = 1800 // 30 minutes
        exercise2.distance = 5.0
        
        workout.exercises = [exercise1, exercise2]
        
        // When - Complete the workout
        user.completeWorkout(workout)
        
        // Then - Verify all systems work together
        #expect(user.workouts.count == 1)
        #expect(user.totalExperience == workout.totalExperience)
        #expect(user.level >= 1)
        
        // Verify companion gained XP (should equal workout XP since it started at 0)
        let activeCompanion = user.companions.first(where: { $0.id == user.activeCompanionId })!
        #expect(activeCompanion.experience == workout.totalExperience)
        #expect(activeCompanion.experience > 0)
        
        // Verify workout was properly linked to companion
        #expect(user.workouts.first?.companionUsed == companionId)
    }
    
    @Test func testCompleteUserJourneyWithEvolution() async throws {
        // Given - User with evolution-ready companion
        var user = User(username: "evotest", trainerName: "Evolution Tester")
        let companion = Companion(name: "EvoStarter", type: .aqua, evolutionLevel: 2, evolvedForm: "EvoFinal")
        user.addCompanion(companion)
        
        // Create high-XP workout to trigger evolution
        var workout = Workout()
        var exercise = Exercise(name: "Super Training", type: .strength)
        exercise.sets = 20
        exercise.reps = 20
        exercise.weight = 100.0
        workout.exercises = [exercise]
        
        let originalName = companion.name
        
        // When
        user.completeWorkout(workout)
        
        // Then - Verify evolution occurred
        let evolvedCompanion = user.companions.first!
        #expect(evolvedCompanion.level >= 2)
        
        if evolvedCompanion.level >= 2 {
            #expect(evolvedCompanion.name == "EvoFinal")
            #expect(evolvedCompanion.name != originalName)
        }
    }
    
    @Test func testBadgeSystemIntegration() async throws {
        // Given
        var user = User(username: "badgetest", trainerName: "Badge Tester")
        let companion = Companion(name: "BadgeMon", type: .warrior)
        user.addCompanion(companion)
        
        // When - Complete enough workouts for week badge
        for i in 1...7 {
            var workout = Workout()
            var exercise = Exercise(name: "Workout \(i)", type: .strength)
            exercise.sets = 1
            exercise.reps = 1
            workout.exercises = [exercise]
            user.completeWorkout(workout)
        }
        
        // Then
        #expect(user.badges.count > 0)
        #expect(user.badges.contains { $0.type == .weekStreak })
        #expect(user.workouts.count == 7)
    }
    
    // MARK: - Data Consistency Tests
    
    @Test func testDataModelConsistency() async throws {
        // Given - All starter companions
        let starters = starterCompanions
        
        // When & Then - Verify each starter is valid
        for starter in starters {
            #expect(starter.level == 1)
            #expect(starter.experience == 0)
            #expect(starter.evolutionLevel != nil)
            #expect(starter.evolvedForm != nil)
            #expect(starter.baseStats.hp > 0)
            #expect(starter.baseStats.attack > 0)
            #expect(starter.baseStats.defense > 0)
            #expect(starter.baseStats.speed > 0)
        }
        
        // Verify all types are represented
        let allTypes = Set(CompanionType.allCases)
        let starterTypes = Set(starters.map { $0.type })
        #expect(allTypes == starterTypes)
    }
    
    @Test func testExerciseXPBalance() async throws {
        // Test that different exercise types provide reasonable XP
        
        // Strength exercise
        var strengthEx = Exercise(name: "Bench Press", type: .strength)
        strengthEx.sets = 3
        strengthEx.reps = 10
        strengthEx.weight = 80.0
        
        // Cardio exercise  
        var cardioEx = Exercise(name: "Running", type: .cardio)
        cardioEx.duration = 1800 // 30 minutes
        cardioEx.distance = 5.0
        
        // Flexibility exercise
        var flexEx = Exercise(name: "Yoga", type: .flexibility)
        flexEx.duration = 3600 // 60 minutes
        
        let strengthXP = strengthEx.experiencePoints
        let cardioXP = cardioEx.experiencePoints
        let flexXP = flexEx.experiencePoints
        
        // All should provide meaningful XP
        #expect(strengthXP > 10)
        #expect(cardioXP > 10)
        #expect(flexXP > 10)
        
        // Verify multipliers work correctly by comparing base values
        // Strength has highest multiplier (1.5x vs 1.2x vs 1.0x)
        let strengthMultiplier = ExerciseType.strength.experienceMultiplier
        let cardioMultiplier = ExerciseType.cardio.experienceMultiplier
        let flexMultiplier = ExerciseType.flexibility.experienceMultiplier
        
        #expect(strengthMultiplier > cardioMultiplier)
        #expect(cardioMultiplier > flexMultiplier)
    }
    
    // MARK: - Performance Tests
    
    @Test func testLargeDataHandling() async throws {
        // Given - User with many companions and workouts
        var user = User(username: "performance", trainerName: "Performance Tester")
        
        // Add multiple companions
        for i in 1...8 {
            let companion = Companion(name: "Companion\(i)", type: CompanionType.allCases[i-1])
            user.addCompanion(companion)
        }
        
        // Add many workouts
        for i in 1...50 {
            var workout = Workout()
            var exercise = Exercise(name: "Exercise \(i)", type: .strength)
            exercise.sets = 3
            exercise.reps = 10
            workout.exercises = [exercise]
            user.completeWorkout(workout)
        }
        
        // When & Then - Should handle large datasets without issues
        #expect(user.companions.count == 8)
        #expect(user.workouts.count == 50)
        #expect(user.totalExperience > 0)
        #expect(user.level > 1)
        
        // Should have multiple badges
        #expect(user.badges.count >= 2) // Week and month streaks
    }
    
    // MARK: - Serialization Tests
    
    @Test func testCompleteUserSerialization() async throws {
        // Given - Complex user with all data types
        var user = User(username: "serialize", trainerName: "Serialization Tester")
        
        // Add companions
        let companion1 = Companion(name: "Companion1", type: .flame)
        let companion2 = Companion(name: "Companion2", type: .aqua)
        user.addCompanion(companion1)
        user.addCompanion(companion2)
        user.updateCompanionNickname(companion1.id, nickname: "Flamey")
        
        // Add workouts
        var workout = Workout()
        var exercise = Exercise(name: "Test Ex", type: .strength)
        exercise.sets = 3
        exercise.reps = 10
        exercise.weight = 50.0
        exercise.notes = "Test notes"
        workout.exercises = [exercise]
        workout.notes = "Workout notes"
        user.completeWorkout(workout)
        
        // When
        let encoded = try JSONEncoder().encode(user)
        let decoded = try JSONDecoder().decode(User.self, from: encoded)
        
        // Then - Everything should be preserved
        #expect(decoded.username == user.username)
        #expect(decoded.companions.count == user.companions.count)
        #expect(decoded.workouts.count == user.workouts.count)
        #expect(decoded.badges.count == user.badges.count)
        #expect(decoded.totalExperience == user.totalExperience)
        #expect(decoded.level == user.level)
        
        // Check companion details
        let decodedCompanion = decoded.companions.first { $0.id == companion1.id }
        #expect(decodedCompanion?.nickname == "Flamey")
        
        // Check workout details
        #expect(decoded.workouts.first?.exercises.first?.notes == "Test notes")
        #expect(decoded.workouts.first?.notes == "Workout notes")
    }
}
