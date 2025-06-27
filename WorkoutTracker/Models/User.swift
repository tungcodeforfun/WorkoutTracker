//
//  User.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation

/// Represents a user's complete profile and fitness journey in CompanionFit.
/// 
/// The User model encapsulates all user data including personal information, companion collection,
/// workout history, achievements, and progression. All data is stored locally on the device using
/// UserDefaults for privacy and simplicity.
///
/// Key features:
/// - Companion management with active companion selection
/// - Complete workout history tracking
/// - Achievement and badge system
/// - Level progression based on total experience
/// - Friend system for future social features
struct User: Identifiable, Codable {
    let id: UUID
    var username: String
    var trainerName: String
    var level: Int
    var totalExperience: Int
    var companions: [Companion]
    var activeCompanionId: UUID?
    var workouts: [Workout]
    var badges: [Badge]
    var friends: [UUID]
    var joinDate: Date
    
    init(username: String, trainerName: String) {
        self.id = UUID()
        self.username = username
        self.trainerName = trainerName
        self.level = 1
        self.totalExperience = 0
        self.companions = []
        self.workouts = []
        self.badges = []
        self.friends = []
        self.joinDate = Date()
    }
    
    var activeCompanion: Companion? {
        guard let activeCompanionId = activeCompanionId else { return nil }
        return companions.first { $0.id == activeCompanionId }
    }
    
    mutating func addCompanion(_ newCompanion: Companion) {
        companions.append(newCompanion)
        if activeCompanionId == nil {
            activeCompanionId = newCompanion.id
        }
    }
    
    mutating func setActiveCompanion(_ companionId: UUID) {
        activeCompanionId = companionId
    }
    
    mutating func updateCompanionNickname(_ companionId: UUID, nickname: String) {
        if let index = companions.firstIndex(where: { $0.id == companionId }) {
            companions[index].nickname = nickname
        }
    }
    
    mutating func completeWorkout(_ workout: Workout) {
        var updatedWorkout = workout
        updatedWorkout.companionUsed = activeCompanionId
        workouts.append(updatedWorkout)
        
        let experienceGained = workout.totalExperience
        totalExperience += experienceGained
        
        if let index = companions.firstIndex(where: { $0.id == activeCompanionId }) {
            companions[index].gainExperience(experienceGained)
        }
        
        checkForLevelUp()
        checkForBadges()
    }
    
    private mutating func checkForLevelUp() {
        let newLevel = totalExperience / 1000 + 1
        if newLevel > level {
            level = newLevel
        }
    }
    
    private mutating func checkForBadges() {
        if workouts.count >= 7 && !badges.contains(where: { $0.type == .weekStreak }) {
            badges.append(Badge(type: .weekStreak))
        }
        
        if workouts.count >= 30 && !badges.contains(where: { $0.type == .monthStreak }) {
            badges.append(Badge(type: .monthStreak))
        }
        
        if companions.contains(where: { $0.level >= 10 }) && !badges.contains(where: { $0.type == .firstEvolution }) {
            badges.append(Badge(type: .firstEvolution))
        }
        
        let totalWeight = workouts.flatMap { $0.exercises }.compactMap { $0.weight }.reduce(0, +)
        if totalWeight >= 10000 && !badges.contains(where: { $0.type == .strongLifter }) {
            badges.append(Badge(type: .strongLifter))
        }
        
        let totalDistance = workouts.flatMap { $0.exercises }.compactMap { $0.distance }.reduce(0, +)
        if totalDistance >= 100 && !badges.contains(where: { $0.type == .marathoner }) {
            badges.append(Badge(type: .marathoner))
        }
    }
}

struct Badge: Identifiable, Codable {
    let id: UUID
    let type: BadgeType
    let earnedDate: Date
    
    init(type: BadgeType) {
        self.id = UUID()
        self.type = type
        self.earnedDate = Date()
    }
}

enum BadgeType: String, CaseIterable, Codable {
    case weekStreak = "Week Warrior"
    case monthStreak = "Monthly Master"
    case firstEvolution = "Evolution Expert"
    case strongLifter = "Strong Trainer"
    case marathoner = "Distance Champion"
    
    var icon: String {
        switch self {
        case .weekStreak: return "calendar.badge.clock"
        case .monthStreak: return "calendar.badge.plus"
        case .firstEvolution: return "sparkles"
        case .strongLifter: return "figure.strengthtraining.traditional"
        case .marathoner: return "figure.run"
        }
    }
    
    var description: String {
        switch self {
        case .weekStreak: return "Complete 7 workouts"
        case .monthStreak: return "Complete 30 workouts"
        case .firstEvolution: return "Evolve your first Companion"
        case .strongLifter: return "Lift 10,000 kg total"
        case .marathoner: return "Run 100 km total"
        }
    }
}