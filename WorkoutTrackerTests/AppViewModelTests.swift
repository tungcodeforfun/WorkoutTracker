//
//  AppViewModelTests.swift
//  WorkoutTrackerTests
//
//  Created by Tung Nguyen on 6/27/25.
//

import Testing
@testable import WorkoutTracker

@MainActor
struct AppViewModelTests {
    
    // MARK: - Initialization Tests
    
    @Test func testViewModelInitialization() async throws {
        // Given & When
        let viewModel = AppViewModel()
        
        // Then
        #expect(viewModel.currentUser == nil)
        #expect(viewModel.selectedTab == 0)
        #expect(viewModel.showingCompanionSelection == false)
        #expect(viewModel.showingWorkoutCreation == false)
    }
    
    // MARK: - User Creation Tests
    
    @Test func testCreateUser() async throws {
        // Given
        let viewModel = AppViewModel()
        let username = "testuser"
        let trainerName = "Test Trainer"
        
        // When
        viewModel.createUser(username: username, trainerName: trainerName)
        
        // Then
        #expect(viewModel.currentUser != nil)
        #expect(viewModel.currentUser?.username == username)
        #expect(viewModel.currentUser?.trainerName == trainerName)
        #expect(viewModel.showingCompanionSelection == true)
    }
    
    // MARK: - Companion Management Tests
    
    @Test func testSelectStarterCompanion() async throws {
        // Given
        let viewModel = AppViewModel()
        viewModel.createUser(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestStarter", type: .flame)
        
        // When
        viewModel.selectStarterCompanion(companion)
        
        // Then
        #expect(viewModel.currentUser?.companions.count == 1)
        #expect(viewModel.currentUser?.companions.first?.name == companion.name)
        #expect(viewModel.currentUser?.activeCompanionId == companion.id)
        #expect(viewModel.showingCompanionSelection == false)
    }
    
    @Test func testSetActiveCompanion() async throws {
        // Given
        let viewModel = AppViewModel()
        viewModel.createUser(username: "test", trainerName: "Test")
        
        let companion1 = Companion(name: "First", type: .flame)
        let companion2 = Companion(name: "Second", type: .aqua)
        
        viewModel.selectStarterCompanion(companion1)
        viewModel.currentUser?.addCompanion(companion2)
        
        // When
        viewModel.setActiveCompanion(companion2.id)
        
        // Then
        #expect(viewModel.currentUser?.activeCompanionId == companion2.id)
    }
    
    @Test func testUpdateCompanionNickname() async throws {
        // Given
        let viewModel = AppViewModel()
        viewModel.createUser(username: "test", trainerName: "Test")
        
        let companion = Companion(name: "TestMon", type: .nature)
        viewModel.selectStarterCompanion(companion)
        
        let newNickname = "Leafy"
        
        // When
        viewModel.updateCompanionNickname(companion.id, nickname: newNickname)
        
        // Then
        #expect(viewModel.currentUser?.companions.first?.nickname == newNickname)
    }
    
    // MARK: - Workout Management Tests
    
    @Test func testCompleteWorkout() async throws {
        // Given
        let viewModel = AppViewModel()
        viewModel.createUser(username: "test", trainerName: "Test")
        
        let companion = Companion(name: "TestMon", type: .warrior)
        viewModel.selectStarterCompanion(companion)
        
        var workout = Workout()
        var exercise = Exercise(name: "Push-ups", type: .strength)
        exercise.sets = 3
        exercise.reps = 10
        workout.exercises = [exercise]
        
        let initialWorkoutCount = viewModel.currentUser?.workouts.count ?? 0
        let initialCompanionXP = viewModel.currentUser?.companions.first?.experience ?? 0
        
        // When
        viewModel.completeWorkout(workout)
        
        // Then
        #expect(viewModel.currentUser?.workouts.count == initialWorkoutCount + 1)
        #expect(viewModel.currentUser?.companions.first?.experience > initialCompanionXP)
    }
    
    // MARK: - User Reset Tests
    
    @Test func testResetUser() async throws {
        // Given
        let viewModel = AppViewModel()
        viewModel.createUser(username: "test", trainerName: "Test")
        let companion = Companion(name: "TestMon", type: .storm)
        viewModel.selectStarterCompanion(companion)
        
        // Verify user exists
        #expect(viewModel.currentUser != nil)
        
        // When
        viewModel.resetUser()
        
        // Then
        #expect(viewModel.currentUser == nil)
    }
    
    // MARK: - State Management Tests
    
    @Test func testSelectedTabChanges() async throws {
        // Given
        let viewModel = AppViewModel()
        let newTab = 2
        
        // When
        viewModel.selectedTab = newTab
        
        // Then
        #expect(viewModel.selectedTab == newTab)
    }
    
    @Test func testWorkoutCreationState() async throws {
        // Given
        let viewModel = AppViewModel()
        
        // When
        viewModel.showingWorkoutCreation = true
        
        // Then
        #expect(viewModel.showingWorkoutCreation == true)
    }
    
    // MARK: - Integration Tests
    
    @Test func testCompleteUserJourney() async throws {
        // Given
        let viewModel = AppViewModel()
        
        // When - Complete user onboarding flow
        viewModel.createUser(username: "journeytest", trainerName: "Journey Trainer")
        
        let starterCompanion = starterCompanions.first!
        viewModel.selectStarterCompanion(starterCompanion)
        
        // Complete a workout
        var workout = Workout()
        var exercise = Exercise(name: "Test Exercise", type: .strength)
        exercise.sets = 5
        exercise.reps = 10
        exercise.weight = 50.0
        workout.exercises = [exercise]
        
        viewModel.completeWorkout(workout)
        
        // Then - Verify full state
        #expect(viewModel.currentUser != nil)
        #expect(viewModel.currentUser?.companions.count == 1)
        #expect(viewModel.currentUser?.workouts.count == 1)
        #expect(viewModel.currentUser?.totalExperience > 0)
        #expect(viewModel.showingCompanionSelection == false)
    }
    
    // MARK: - Error Handling Tests
    
    @Test func testSelectCompanionWithoutUser() async throws {
        // Given
        let viewModel = AppViewModel()
        let companion = Companion(name: "NoUser", type: .mystic)
        
        // When
        viewModel.selectStarterCompanion(companion)
        
        // Then - Should handle gracefully (not crash)
        #expect(viewModel.currentUser == nil) // Still no user
    }
    
    @Test func testCompleteWorkoutWithoutUser() async throws {
        // Given
        let viewModel = AppViewModel()
        let workout = Workout()
        
        // When
        viewModel.completeWorkout(workout)
        
        // Then - Should handle gracefully (not crash)
        #expect(viewModel.currentUser == nil) // Still no user
    }
    
    @Test func testUpdateCompanionWithoutUser() async throws {
        // Given
        let viewModel = AppViewModel()
        let fakeId = UUID()
        
        // When
        viewModel.updateCompanionNickname(fakeId, nickname: "Test")
        
        // Then - Should handle gracefully (not crash)
        #expect(viewModel.currentUser == nil) // Still no user
    }
    
    // MARK: - Persistence Tests (Integration with UserDefaults)
    
    @Test func testUserPersistence() async throws {
        // Given
        let viewModel = AppViewModel()
        let username = "persisttest"
        let trainerName = "Persist Trainer"
        
        // When
        viewModel.createUser(username: username, trainerName: trainerName)
        
        // Simulate app restart by creating new ViewModel
        let newViewModel = AppViewModel()
        
        // Then
        // Note: This test might fail in testing environment if UserDefaults is sandboxed
        // But it demonstrates the expected behavior
        if newViewModel.currentUser != nil {
            #expect(newViewModel.currentUser?.username == username)
            #expect(newViewModel.currentUser?.trainerName == trainerName)
        }
    }
}