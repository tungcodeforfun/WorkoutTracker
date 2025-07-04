//
//  Companion.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation
import SwiftUI

/// Represents the different elemental types that companions can have.
/// Each type has unique visual characteristics and represents different training styles.

enum CompanionType: String, CaseIterable, Codable {
    case flame = "Flame"      /// Fire-type companions, passionate and energetic
    case aqua = "Aqua"        /// Water-type companions, calm and flowing
    case nature = "Nature"    /// Plant-type companions, growth and harmony focused
    case storm = "Storm"      /// Electric-type companions, quick and powerful
    case warrior = "Warrior"  /// Fighting-type companions, strength and discipline
    case mystic = "Mystic"    /// Psychic-type companions, mental focus and clarity
    case earth = "Earth"      /// Ground-type companions, stability and endurance
    case wind = "Wind"        /// Flying-type companions, freedom and agility
    
    /// Returns the signature color associated with each companion type
    var color: Color {
        switch self {
        case .flame: return Color(red: 1.00, green: 0.31, blue: 0.26)      // Modern red
        case .aqua: return Color(red: 0.20, green: 0.60, blue: 1.00)      // Modern blue
        case .nature: return Color(red: 0.30, green: 0.85, blue: 0.45)     // Modern green
        case .storm: return Color(red: 1.00, green: 0.80, blue: 0.00)      // Modern yellow
        case .warrior: return Color(red: 1.00, green: 0.45, blue: 0.20)    // Modern orange
        case .mystic: return Color(red: 0.85, green: 0.40, blue: 0.95)     // Modern purple
        case .earth: return Color(red: 0.55, green: 0.45, blue: 0.35)      // Modern brown
        case .wind: return Color(red: 0.40, green: 0.75, blue: 1.00)       // Modern sky blue
        }
    }
}

/// A digital training companion that grows stronger through workouts.
/// Each companion has unique stats, elemental typing, and evolution potential.
///
/// Companions gain experience points (XP) when users complete workouts, allowing them to level up
/// and eventually evolve into more powerful forms. This gamification system encourages consistent
/// fitness activity by providing meaningful progression for the user's virtual partner.
struct Companion: Identifiable, Codable {
    let id: UUID
    var name: String
    var nickname: String?
    var type: CompanionType
    var level: Int
    var experience: Int
    var baseStats: CompanionStats
    var currentStats: CompanionStats
    var evolutionLevel: Int?
    var evolvedForm: String?
    
    init(name: String, type: CompanionType, evolutionLevel: Int? = nil, evolvedForm: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.level = 1
        self.experience = 0
        self.evolutionLevel = evolutionLevel
        self.evolvedForm = evolvedForm
        
        let baseValue = 50
        self.baseStats = CompanionStats(
            hp: baseValue + Int.random(in: -10...10),
            attack: baseValue + Int.random(in: -10...10),
            defense: baseValue + Int.random(in: -10...10),
            speed: baseValue + Int.random(in: -10...10)
        )
        self.currentStats = baseStats
    }
    
    mutating func gainExperience(_ amount: Int) {
        experience += amount
        
        while experience >= experienceForNextLevel() {
            experience -= experienceForNextLevel()
            levelUp()
        }
    }
    
    func experienceForNextLevel() -> Int {
        level * 100
    }
    
    private mutating func levelUp() {
        level += 1
        
        // Increase stats
        currentStats.hp += Int.random(in: 2...5)
        currentStats.attack += Int.random(in: 2...5)
        currentStats.defense += Int.random(in: 2...5)
        currentStats.speed += Int.random(in: 2...5)
        
        // Check for evolution
        if let evolutionLevel = evolutionLevel,
           level >= evolutionLevel,
           let evolvedForm = evolvedForm {
            name = evolvedForm
            self.evolvedForm = nil // Can't evolve further
        }
    }
}

struct CompanionStats: Codable {
    var hp: Int
    var attack: Int
    var defense: Int
    var speed: Int
}

// Starter companions with new names
let starterCompanions = [
    Companion(name: "Embercub", type: .flame, evolutionLevel: 16, evolvedForm: "Blazelion"),
    Companion(name: "Aquapup", type: .aqua, evolutionLevel: 16, evolvedForm: "Tidalwolf"),
    Companion(name: "Leafling", type: .nature, evolutionLevel: 16, evolvedForm: "Verdantbear"),
    Companion(name: "Sparkkit", type: .storm, evolutionLevel: 20, evolvedForm: "Thunderlynx"),
    Companion(name: "Brawlpaw", type: .warrior, evolutionLevel: 28, evolvedForm: "Ironbeast"),
    Companion(name: "Mindling", type: .mystic, evolutionLevel: 16, evolvedForm: "Psyfox"),
    Companion(name: "Pebblecub", type: .earth, evolutionLevel: 25, evolvedForm: "Boulderbear"),
    Companion(name: "Breezeling", type: .wind, evolutionLevel: 18, evolvedForm: "Galehawk")
]