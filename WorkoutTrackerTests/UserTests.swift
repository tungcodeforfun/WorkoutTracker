//
//  UserTests.swift
//  WorkoutTrackerTests
//
//  Created by Tung Nguyen on 6/27/25.
//

import Testing
@testable import WorkoutTracker

struct UserTests {
    
    // MARK: - User Creation Tests
    
    @Test func testUserInitialization() async throws {
        // Given
        let username = "testuser"
        let trainerName = "Test Trainer"
        
        // When
        let user = User(username: username, trainerName: trainerName)
        
        // Then
        #expect(user.username == username)
        #expect(user.trainerName == trainerName)
        #expect(user.level == 1)
        #expect(user.totalExperience == 0)
        #expect(user.companions.isEmpty)
        #expect(user.activeCompanionId == nil)
        #expect(user.workouts.isEmpty)
        #expect(user.badges.isEmpty)
        #expect(user.friends.isEmpty)
    }
    
    // MARK: - Companion Management Tests
    
    @Test func testAddCompanion() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .flame)
        
        // When
        user.addCompanion(companion)
        
        // Then
        #expect(user.companions.count == 1)
        #expect(user.companions.first?.id == companion.id)
        #expect(user.activeCompanionId == companion.id) // Should auto-set as active
    }
    
    @Test func testAddMultipleCompanions() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion1 = Companion(name: "First", type: .flame)
        let companion2 = Companion(name: "Second", type: .aqua)
        
        // When
        user.addCompanion(companion1)
        user.addCompanion(companion2)
        
        // Then
        #expect(user.companions.count == 2)
        #expect(user.activeCompanionId == companion1.id) // First one should remain active
    }
    
    @Test func testSetActiveCompanion() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion1 = Companion(name: "First", type: .flame)
        let companion2 = Companion(name: "Second", type: .aqua)
        user.addCompanion(companion1)
        user.addCompanion(companion2)
        
        // When
        user.setActiveCompanion(companion2.id)
        
        // Then
        #expect(user.activeCompanionId == companion2.id)
    }
    
    @Test func testActiveCompanionProperty() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .nature)
        user.addCompanion(companion)
        
        // When
        let activeCompanion = user.activeCompanion
        
        // Then
        #expect(activeCompanion?.id == companion.id)
        #expect(activeCompanion?.name == companion.name)
    }
    
    @Test func testActiveCompanionWithNoCompanions() async throws {
        // Given
        let user = User(username: "test", trainerName: "Test")
        
        // When
        let activeCompanion = user.activeCompanion
        
        // Then
        #expect(activeCompanion == nil)
    }
    
    @Test func testUpdateCompanionNickname() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        var companion = Companion(name: "TestMon", type: .storm)
        user.addCompanion(companion)
        let newNickname = "Sparky"
        
        // When
        user.updateCompanionNickname(companion.id, nickname: newNickname)
        
        // Then
        #expect(user.companions.first?.nickname == newNickname)
    }
    
    // MARK: - Workout Completion Tests
    
    @Test func testCompleteWorkout() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .warrior)
        user.addCompanion(companion)
        
        var workout = Workout()
        var exercise = Exercise(name: "Push-ups", type: .strength)
        exercise.sets = 3
        exercise.reps = 10
        workout.exercises = [exercise]
        
        let initialCompanionXP = user.companions.first!.experience
        let initialUserXP = user.totalExperience
        
        // When
        user.completeWorkout(workout)
        
        // Then
        #expect(user.workouts.count == 1)
        #expect(user.workouts.first?.companionUsed == companion.id)
        #expect(user.totalExperience > initialUserXP)
        #expect(user.companions.first!.experience > initialCompanionXP)
    }
    
    @Test func testWorkoutXPDistribution() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .mystic)
        user.addCompanion(companion)
        
        var workout = Workout()
        var exercise = Exercise(name: "Test", type: .strength)
        exercise.sets = 2
        exercise.reps = 5
        workout.exercises = [exercise]
        
        let expectedXP = workout.totalExperience
        
        // When
        user.completeWorkout(workout)
        
        // Then
        #expect(user.totalExperience == expectedXP)
        #expect(user.companions.first!.experience == expectedXP)
    }
    
    // MARK: - Level Up Tests
    
    @Test func testUserLevelUp() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .earth)
        user.addCompanion(companion)
        
        var workout = Workout()
        var exercise = Exercise(name: "Heavy Lifting", type: .strength)
        exercise.sets = 10
        exercise.reps = 10
        exercise.weight = 100
        workout.exercises = [exercise]
        
        // When
        user.completeWorkout(workout)
        
        // Then
        let expectedLevel = user.totalExperience / 1000 + 1
        #expect(user.level == expectedLevel)
    }
    
    // MARK: - Badge System Tests
    
    @Test func testWeekStreakBadge() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .wind)
        user.addCompanion(companion)
        
        // When - Complete 7 workouts
        for _ in 1...7 {
            let workout = Workout()
            user.completeWorkout(workout)
        }
        
        // Then
        #expect(user.badges.contains { $0.type == .weekStreak })
    }
    
    @Test func testMonthStreakBadge() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .flame)
        user.addCompanion(companion)
        
        // When - Complete 30 workouts
        for _ in 1...30 {
            let workout = Workout()
            user.completeWorkout(workout)
        }
        
        // Then
        #expect(user.badges.contains { $0.type == .monthStreak })
        #expect(user.badges.contains { $0.type == .weekStreak }) // Should also have week badge
    }
    
    @Test func testFirstEvolutionBadge() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        var companion = Companion(name: "TestMon", type: .aqua, evolutionLevel: 2, evolvedForm: "EvolvedMon")
        user.addCompanion(companion)
        
        // Create a workout with enough XP to reach level 10+
        var workout = Workout()
        var exercise = Exercise(name: "Super Training", type: .strength)
        exercise.sets = 50
        exercise.reps = 50
        exercise.weight = 1000
        workout.exercises = [exercise]
        
        // When
        user.completeWorkout(workout)
        
        // Then
        #expect(user.badges.contains { $0.type == .firstEvolution })
    }
    
    @Test func testStrongLifterBadge() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .warrior)
        user.addCompanion(companion)
        
        // When - Lift 10,000 kg total
        var workout = Workout()
        var exercise = Exercise(name: "Heavy Lift", type: .strength)
        exercise.weight = 10000.0
        exercise.sets = 1
        exercise.reps = 1
        workout.exercises = [exercise]
        user.completeWorkout(workout)
        
        // Then
        #expect(user.badges.contains { $0.type == .strongLifter })
    }
    
    @Test func testMarathonerBadge() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .wind)
        user.addCompanion(companion)
        
        // When - Run 100 km total
        var workout = Workout()
        var exercise = Exercise(name: "Long Run", type: .cardio)
        exercise.distance = 100.0
        workout.exercises = [exercise]
        user.completeWorkout(workout)
        
        // Then
        #expect(user.badges.contains { $0.type == .marathoner })
    }
    
    @Test func testNoDuplicateBadges() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .nature)
        user.addCompanion(companion)
        
        // When - Complete multiple sets of 7 workouts
        for _ in 1...14 {
            let workout = Workout()
            user.completeWorkout(workout)
        }
        
        // Then
        let weekBadges = user.badges.filter { $0.type == .weekStreak }
        #expect(weekBadges.count == 1) // Should only have one week badge
    }
    
    // MARK: - Badge Type Tests
    
    @Test func testBadgeTypeProperties() async throws {
        // Given & When & Then
        #expect(BadgeType.weekStreak.rawValue == "Week Warrior")
        #expect(BadgeType.monthStreak.rawValue == "Monthly Master")
        #expect(BadgeType.firstEvolution.rawValue == "Evolution Expert")
        #expect(BadgeType.strongLifter.rawValue == "Strong Trainer")
        #expect(BadgeType.marathoner.rawValue == "Distance Champion")
        
        // Test icons
        #expect(BadgeType.weekStreak.icon == "calendar.badge.clock")
        #expect(BadgeType.monthStreak.icon == "calendar.badge.plus")
        #expect(BadgeType.firstEvolution.icon == "sparkles")
        #expect(BadgeType.strongLifter.icon == "figure.strengthtraining.traditional")
        #expect(BadgeType.marathoner.icon == "figure.run")
    }
    
    @Test func testBadgeInitialization() async throws {
        // Given
        let badgeType = BadgeType.weekStreak
        
        // When
        let badge = Badge(type: badgeType)
        
        // Then
        #expect(badge.type == badgeType)
        #expect(badge.earnedDate <= Date()) // Should be recent
    }
    
    // MARK: - Codable Tests
    
    @Test func testUserCodable() async throws {
        // Given
        var originalUser = User(username: "testuser", trainerName: "Test Trainer")
        let companion = Companion(name: "TestMon", type: .flame)
        originalUser.addCompanion(companion)
        
        let workout = Workout()
        originalUser.completeWorkout(workout)
        
        // When
        let encoded = try JSONEncoder().encode(originalUser)
        let decodedUser = try JSONDecoder().decode(User.self, from: encoded)
        
        // Then
        #expect(decodedUser.id == originalUser.id)
        #expect(decodedUser.username == originalUser.username)
        #expect(decodedUser.trainerName == originalUser.trainerName)
        #expect(decodedUser.level == originalUser.level)
        #expect(decodedUser.totalExperience == originalUser.totalExperience)
        #expect(decodedUser.companions.count == originalUser.companions.count)
        #expect(decodedUser.activeCompanionId == originalUser.activeCompanionId)
        #expect(decodedUser.workouts.count == originalUser.workouts.count)
        #expect(decodedUser.badges.count == originalUser.badges.count)
    }
    
    // MARK: - Edge Cases
    
    @Test func testUpdateNonexistentCompanion() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let fakeId = UUID()
        
        // When
        user.updateCompanionNickname(fakeId, nickname: "ShouldNotWork")
        
        // Then
        // Should not crash, companions should remain unchanged
        #expect(user.companions.isEmpty)
    }
    
    @Test func testSetActiveCompanionToNonexistent() async throws {
        // Given
        var user = User(username: "test", trainerName: "Test")
        let fakeId = UUID()
        
        // When
        user.setActiveCompanion(fakeId)
        
        // Then
        #expect(user.activeCompanionId == fakeId) // Sets it anyway (could be considered a bug)
        #expect(user.activeCompanion == nil) // But returns nil since companion doesn't exist
    }
}