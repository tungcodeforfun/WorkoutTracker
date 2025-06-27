//
//  Workout.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation

enum ExerciseType: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case sports = "Sports"
    case other = "Other"
    
    var experienceMultiplier: Double {
        switch self {
        case .strength: return 1.5
        case .cardio: return 1.2
        case .flexibility: return 1.0
        case .sports: return 1.3
        case .other: return 1.0
        }
    }
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var type: ExerciseType
    var sets: Int?
    var reps: Int?
    var weight: Double?
    var duration: TimeInterval?
    var distance: Double?
    var notes: String?
    
    init(name: String, type: ExerciseType) {
        self.id = UUID()
        self.name = name
        self.type = type
    }
    
    var experiencePoints: Int {
        var baseXP = 10
        
        if let sets = sets, let reps = reps {
            baseXP += sets * reps * 2
        }
        
        if let weight = weight {
            baseXP += Int(weight / 10)
        }
        
        if let duration = duration {
            baseXP += Int(duration / 60) * 5
        }
        
        if let distance = distance {
            baseXP += Int(distance * 10)
        }
        
        return Int(Double(baseXP) * type.experienceMultiplier)
    }
}

struct Workout: Identifiable, Codable {
    let id: UUID
    var date: Date
    var exercises: [Exercise]
    var totalDuration: TimeInterval
    var notes: String?
    var companionUsed: UUID?
    
    init(date: Date = Date()) {
        self.id = UUID()
        self.date = date
        self.exercises = []
        self.totalDuration = 0
    }
    
    var totalExperience: Int {
        exercises.reduce(0) { $0 + $1.experiencePoints }
    }
}

let commonExercises: [String: ExerciseType] = [
    "Push-ups": .strength,
    "Pull-ups": .strength,
    "Squats": .strength,
    "Deadlift": .strength,
    "Bench Press": .strength,
    "Running": .cardio,
    "Cycling": .cardio,
    "Swimming": .cardio,
    "Yoga": .flexibility,
    "Stretching": .flexibility,
    "Basketball": .sports,
    "Soccer": .sports,
    "Tennis": .sports
]