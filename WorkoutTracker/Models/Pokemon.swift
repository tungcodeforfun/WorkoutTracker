//
//  Pokemon.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import Foundation
import SwiftUI

enum PokemonType: String, CaseIterable, Codable {
    case fire = "Fire"
    case water = "Water"
    case grass = "Grass"
    case electric = "Electric"
    case fighting = "Fighting"
    case psychic = "Psychic"
    case rock = "Rock"
    case flying = "Flying"
    
    var color: Color {
        switch self {
        case .fire: return Color(red: 1.00, green: 0.31, blue: 0.26)      // Modern red
        case .water: return Color(red: 0.20, green: 0.60, blue: 1.00)     // Modern blue
        case .grass: return Color(red: 0.30, green: 0.85, blue: 0.45)     // Modern green
        case .electric: return Color(red: 1.00, green: 0.80, blue: 0.00)  // Modern yellow
        case .fighting: return Color(red: 1.00, green: 0.45, blue: 0.20)  // Modern orange
        case .psychic: return Color(red: 0.85, green: 0.40, blue: 0.95)   // Modern purple
        case .rock: return Color(red: 0.55, green: 0.45, blue: 0.35)      // Modern brown
        case .flying: return Color(red: 0.40, green: 0.75, blue: 1.00)    // Modern sky blue
        }
    }
}

struct Pokemon: Identifiable, Codable {
    let id: UUID
    var name: String
    var nickname: String?
    var type: PokemonType
    var level: Int
    var experience: Int
    var evolutionLevel: Int?
    var evolvedForm: String?
    var baseStats: Stats
    var currentStats: Stats
    
    struct Stats: Codable {
        var hp: Int
        var attack: Int
        var defense: Int
        var speed: Int
    }
    
    init(name: String, type: PokemonType, evolutionLevel: Int? = nil, evolvedForm: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.level = 1
        self.experience = 0
        self.evolutionLevel = evolutionLevel
        self.evolvedForm = evolvedForm
        self.baseStats = Stats(hp: 50, attack: 50, defense: 50, speed: 50)
        self.currentStats = baseStats
    }
    
    mutating func gainExperience(_ exp: Int) {
        experience += exp
        while experience >= experienceForNextLevel() {
            levelUp()
        }
    }
    
    private mutating func levelUp() {
        level += 1
        currentStats.hp += 2
        currentStats.attack += 2
        currentStats.defense += 2
        currentStats.speed += 2
        
        if let evolutionLevel = evolutionLevel,
           level >= evolutionLevel,
           let evolvedForm = evolvedForm {
            evolve(to: evolvedForm)
        }
    }
    
    private mutating func evolve(to newForm: String) {
        name = newForm
        currentStats.hp += 10
        currentStats.attack += 10
        currentStats.defense += 10
        currentStats.speed += 10
    }
    
    func experienceForNextLevel() -> Int {
        return level * 100
    }
}

let starterPokemon = [
    Pokemon(name: "Charmander", type: .fire, evolutionLevel: 16, evolvedForm: "Charmeleon"),
    Pokemon(name: "Squirtle", type: .water, evolutionLevel: 16, evolvedForm: "Wartortle"),
    Pokemon(name: "Bulbasaur", type: .grass, evolutionLevel: 16, evolvedForm: "Ivysaur"),
    Pokemon(name: "Pikachu", type: .electric, evolutionLevel: 20, evolvedForm: "Raichu"),
    Pokemon(name: "Machop", type: .fighting, evolutionLevel: 28, evolvedForm: "Machoke"),
    Pokemon(name: "Abra", type: .psychic, evolutionLevel: 16, evolvedForm: "Kadabra"),
    Pokemon(name: "Geodude", type: .rock, evolutionLevel: 25, evolvedForm: "Graveler"),
    Pokemon(name: "Pidgey", type: .flying, evolutionLevel: 18, evolvedForm: "Pidgeotto")
]