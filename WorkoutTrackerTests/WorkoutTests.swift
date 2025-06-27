//
//  WorkoutTests.swift
//  WorkoutTrackerTests
//
//  Created by Tung Nguyen on 6/27/25.
//

import Testing
@testable import WorkoutTracker

struct WorkoutTests {
    
    // MARK: - Exercise Creation Tests
    
    @Test func testExerciseInitialization() async throws {
        // Given
        let name = "Push-ups"
        let type = ExerciseType.strength
        
        // When
        let exercise = Exercise(name: name, type: type)
        
        // Then
        #expect(exercise.name == name)
        #expect(exercise.type == type)
        #expect(exercise.sets == nil)
        #expect(exercise.reps == nil)
        #expect(exercise.weight == nil)
        #expect(exercise.duration == nil)
        #expect(exercise.distance == nil)
        #expect(exercise.notes == nil)
    }
    
    // MARK: - XP Calculation Tests
    
    @Test func testStrengthExerciseXPCalculation() async throws {
        // Given
        var exercise = Exercise(name: "Bench Press", type: .strength)
        exercise.sets = 3
        exercise.reps = 10
        exercise.weight = 80.0
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Base: 10 + (3 * 10 * 2) + (80 / 10) = 10 + 60 + 8 = 78
        // With 1.5x multiplier: 78 * 1.5 = 117
        #expect(xp == 117)
    }
    
    @Test func testCardioExerciseXPCalculation() async throws {
        // Given
        var exercise = Exercise(name: "Running", type: .cardio)
        exercise.duration = 1800 // 30 minutes in seconds
        exercise.distance = 5.0 // 5 km
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Base: 10 + (1800 / 60 * 5) + (5.0 * 10) = 10 + 150 + 50 = 210
        // With 1.2x multiplier: 210 * 1.2 = 252
        #expect(xp == 252)
    }
    
    @Test func testFlexibilityExerciseXPCalculation() async throws {
        // Given
        var exercise = Exercise(name: "Yoga", type: .flexibility)
        exercise.duration = 3600 // 60 minutes
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Base: 10 + (3600 / 60 * 5) = 10 + 300 = 310
        // With 1.0x multiplier: 310 * 1.0 = 310
        #expect(xp == 310)
    }
    
    @Test func testMinimalExerciseXP() async throws {
        // Given
        let exercise = Exercise(name: "Test", type: .other)
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Just base XP with 1.0x multiplier
        #expect(xp == 10)
    }
    
    // MARK: - Exercise Type Multiplier Tests
    
    @Test func testExerciseTypeMultipliers() async throws {
        // Given & When & Then
        #expect(ExerciseType.strength.experienceMultiplier == 1.5)
        #expect(ExerciseType.cardio.experienceMultiplier == 1.2)
        #expect(ExerciseType.flexibility.experienceMultiplier == 1.0)
        #expect(ExerciseType.sports.experienceMultiplier == 1.3)
        #expect(ExerciseType.other.experienceMultiplier == 1.0)
    }
    
    // MARK: - Workout Tests
    
    @Test func testWorkoutInitialization() async throws {
        // Given
        let date = Date()
        
        // When
        let workout = Workout(date: date)
        
        // Then
        #expect(workout.date == date)
        #expect(workout.exercises.isEmpty)
        #expect(workout.totalDuration == 0)
        #expect(workout.notes == nil)
        #expect(workout.companionUsed == nil)
    }
    
    @Test func testWorkoutTotalExperience() async throws {
        // Given
        var workout = Workout()
        
        var exercise1 = Exercise(name: "Push-ups", type: .strength)
        exercise1.sets = 3
        exercise1.reps = 10
        
        var exercise2 = Exercise(name: "Running", type: .cardio)
        exercise2.duration = 1200 // 20 minutes
        
        workout.exercises = [exercise1, exercise2]
        
        // When
        let totalXP = workout.totalExperience
        
        // Then
        let exercise1XP = exercise1.experiencePoints
        let exercise2XP = exercise2.experiencePoints
        #expect(totalXP == exercise1XP + exercise2XP)
        #expect(totalXP > 0)
    }
    
    @Test func testEmptyWorkoutXP() async throws {
        // Given
        let workout = Workout()
        
        // When
        let totalXP = workout.totalExperience
        
        // Then
        #expect(totalXP == 0)
    }
    
    // MARK: - Common Exercises Tests
    
    @Test func testCommonExercisesExist() async throws {
        // Given & When
        let exercises = commonExercises
        
        // Then
        #expect(exercises.count > 0)
        #expect(exercises["Push-ups"] == .strength)
        #expect(exercises["Running"] == .cardio)
        #expect(exercises["Yoga"] == .flexibility)
        #expect(exercises["Basketball"] == .sports)
    }
    
    @Test func testCommonExercisesAllHaveValidTypes() async throws {
        // Given
        let exercises = commonExercises
        
        // When & Then
        for (_, type) in exercises {
            #expect(ExerciseType.allCases.contains(type))
        }
    }
    
    // MARK: - Edge Cases
    
    @Test func testExerciseWithZeroValues() async throws {
        // Given
        var exercise = Exercise(name: "Test", type: .strength)
        exercise.sets = 0
        exercise.reps = 0
        exercise.weight = 0.0
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Should still get base XP with multiplier
        #expect(xp == Int(10 * 1.5))
    }
    
    @Test func testExerciseWithNegativeValues() async throws {
        // Given
        var exercise = Exercise(name: "Test", type: .strength)
        exercise.sets = -1
        exercise.reps = -1
        exercise.weight = -10.0
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Should handle gracefully (negative values might reduce XP but not crash)
        #expect(xp >= 0)
    }
    
    @Test func testExerciseWithVeryLargeValues() async throws {
        // Given
        var exercise = Exercise(name: "Test", type: .strength)
        exercise.sets = 1000
        exercise.reps = 1000
        exercise.weight = 10000.0
        
        // When
        let xp = exercise.experiencePoints
        
        // Then
        // Should handle large numbers without overflow
        #expect(xp > 0)
        #expect(xp < Int.max)
    }
    
    // MARK: - Codable Tests
    
    @Test func testExerciseCodable() async throws {
        // Given
        var originalExercise = Exercise(name: "Test Exercise", type: .sports)
        originalExercise.sets = 3
        originalExercise.reps = 15
        originalExercise.weight = 50.0
        originalExercise.duration = 3600
        originalExercise.distance = 10.0
        originalExercise.notes = "Great workout!"
        
        // When
        let encoded = try JSONEncoder().encode(originalExercise)
        let decodedExercise = try JSONDecoder().decode(Exercise.self, from: encoded)
        
        // Then
        #expect(decodedExercise.id == originalExercise.id)
        #expect(decodedExercise.name == originalExercise.name)
        #expect(decodedExercise.type == originalExercise.type)
        #expect(decodedExercise.sets == originalExercise.sets)
        #expect(decodedExercise.reps == originalExercise.reps)
        #expect(decodedExercise.weight == originalExercise.weight)
        #expect(decodedExercise.duration == originalExercise.duration)
        #expect(decodedExercise.distance == originalExercise.distance)
        #expect(decodedExercise.notes == originalExercise.notes)
    }
    
    @Test func testWorkoutCodable() async throws {
        // Given
        var originalWorkout = Workout()
        originalWorkout.notes = "Test workout"
        originalWorkout.totalDuration = 3600
        originalWorkout.companionUsed = UUID()
        
        let exercise = Exercise(name: "Test", type: .strength)
        originalWorkout.exercises = [exercise]
        
        // When
        let encoded = try JSONEncoder().encode(originalWorkout)
        let decodedWorkout = try JSONDecoder().decode(Workout.self, from: encoded)
        
        // Then
        #expect(decodedWorkout.id == originalWorkout.id)
        #expect(decodedWorkout.exercises.count == originalWorkout.exercises.count)
        #expect(decodedWorkout.totalDuration == originalWorkout.totalDuration)
        #expect(decodedWorkout.notes == originalWorkout.notes)
        #expect(decodedWorkout.companionUsed == originalWorkout.companionUsed)
    }
}