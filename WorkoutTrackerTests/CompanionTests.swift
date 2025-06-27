//
//  CompanionTests.swift
//  WorkoutTrackerTests
//
//  Created by Tung Nguyen on 6/27/25.
//

import Testing
@testable import WorkoutTracker

struct CompanionTests {
    
    // MARK: - Companion Creation Tests
    
    @Test func testCompanionInitialization() async throws {
        // Given
        let name = "TestCompanion"
        let type = CompanionType.flame
        
        // When
        let companion = Companion(name: name, type: type)
        
        // Then
        #expect(companion.name == name)
        #expect(companion.type == type)
        #expect(companion.level == 1)
        #expect(companion.experience == 0)
        #expect(companion.nickname == nil)
        #expect(companion.baseStats.hp >= 40) // 50 ± 10
        #expect(companion.baseStats.hp <= 60)
        #expect(companion.currentStats.hp == companion.baseStats.hp)
    }
    
    @Test func testCompanionWithEvolution() async throws {
        // Given
        let evolutionLevel = 16
        let evolvedForm = "EvolvedForm"
        
        // When
        let companion = Companion(name: "Starter", type: .aqua, evolutionLevel: evolutionLevel, evolvedForm: evolvedForm)
        
        // Then
        #expect(companion.evolutionLevel == evolutionLevel)
        #expect(companion.evolvedForm == evolvedForm)
    }
    
    // MARK: - Experience and Leveling Tests
    
    @Test func testExperienceGainAndLevelUp() async throws {
        // Given
        var companion = Companion(name: "TestMon", type: .nature)
        let initialHP = companion.currentStats.hp
        let experienceToGain = 100 // Should level up once (level 1 needs 100 XP)
        
        // When
        companion.gainExperience(experienceToGain)
        
        // Then
        #expect(companion.level == 2)
        #expect(companion.experience == 0) // Should reset after level up
        #expect(companion.currentStats.hp > initialHP) // Stats should increase
    }
    
    @Test func testMultipleLevelUps() async throws {
        // Given
        var companion = Companion(name: "TestMon", type: .storm)
        let initialLevel = companion.level
        let experienceToGain = 350 // Should level up multiple times
        
        // When
        companion.gainExperience(experienceToGain)
        
        // Then
        #expect(companion.level > initialLevel)
        #expect(companion.experience >= 0)
        #expect(companion.experience < companion.experienceForNextLevel())
    }
    
    @Test func testExperienceForNextLevel() async throws {
        // Given
        let companion = Companion(name: "TestMon", type: .warrior)
        
        // When
        let xpNeeded = companion.experienceForNextLevel()
        
        // Then
        #expect(xpNeeded == companion.level * 100)
    }
    
    // MARK: - Evolution Tests
    
    @Test func testEvolutionTriggersAtCorrectLevel() async throws {
        // Given
        var companion = Companion(name: "Starter", type: .flame, evolutionLevel: 3, evolvedForm: "Evolved")
        let experienceToEvolve = 300 // Should reach level 3
        
        // When
        companion.gainExperience(experienceToEvolve)
        
        // Then
        #expect(companion.level >= 3)
        #expect(companion.name == "Evolved")
        #expect(companion.evolvedForm == nil) // Should be cleared after evolution
    }
    
    @Test func testNoEvolutionWithoutEvolutionData() async throws {
        // Given
        var companion = Companion(name: "NoEvolution", type: .mystic) // No evolution data
        let initialName = companion.name
        
        // When
        companion.gainExperience(1000) // Lots of XP
        
        // Then
        #expect(companion.name == initialName) // Name shouldn't change
        #expect(companion.level > 1) // But should still level up
    }
    
    // MARK: - Stat Growth Tests
    
    @Test func testStatsIncreaseWithLevelUp() async throws {
        // Given
        var companion = Companion(name: "TestMon", type: .earth)
        let initialStats = companion.currentStats
        
        // When
        companion.gainExperience(100) // Level up once
        
        // Then
        #expect(companion.currentStats.hp > initialStats.hp)
        #expect(companion.currentStats.attack > initialStats.attack)
        #expect(companion.currentStats.defense > initialStats.defense)
        #expect(companion.currentStats.speed > initialStats.speed)
        
        // Stats should increase by 2-5 points each
        #expect(companion.currentStats.hp - initialStats.hp >= 2)
        #expect(companion.currentStats.hp - initialStats.hp <= 5)
    }
    
    // MARK: - Companion Type Tests
    
    @Test func testAllCompanionTypesHaveColors() async throws {
        // Given & When & Then
        for type in CompanionType.allCases {
            // Each type should have a valid color
            let color = type.color
            #expect(color != nil)
        }
    }
    
    @Test func testCompanionTypeCount() async throws {
        // Given & When
        let typeCount = CompanionType.allCases.count
        
        // Then
        #expect(typeCount == 8) // We have 8 companion types
    }
    
    // MARK: - Starter Companions Tests
    
    @Test func testStarterCompanionsExist() async throws {
        // Given & When
        let starters = starterCompanions
        
        // Then
        #expect(starters.count == 8) // One for each type
        #expect(starters.allSatisfy { $0.level == 1 })
        #expect(starters.allSatisfy { $0.experience == 0 })
        #expect(starters.allSatisfy { $0.evolutionLevel != nil })
        #expect(starters.allSatisfy { $0.evolvedForm != nil })
    }
    
    @Test func testStarterCompanionsHaveUniqueTypes() async throws {
        // Given
        let starters = starterCompanions
        
        // When
        let types = starters.map { $0.type }
        let uniqueTypes = Set(types)
        
        // Then
        #expect(types.count == uniqueTypes.count) // No duplicate types
    }
    
    // MARK: - Codable Tests
    
    @Test func testCompanionCodable() async throws {
        // Given
        let originalCompanion = Companion(name: "CodableTest", type: .wind, evolutionLevel: 20, evolvedForm: "WindMaster")
        
        // When
        let encoded = try JSONEncoder().encode(originalCompanion)
        let decodedCompanion = try JSONDecoder().decode(Companion.self, from: encoded)
        
        // Then
        #expect(decodedCompanion.id == originalCompanion.id)
        #expect(decodedCompanion.name == originalCompanion.name)
        #expect(decodedCompanion.type == originalCompanion.type)
        #expect(decodedCompanion.level == originalCompanion.level)
        #expect(decodedCompanion.experience == originalCompanion.experience)
        #expect(decodedCompanion.evolutionLevel == originalCompanion.evolutionLevel)
        #expect(decodedCompanion.evolvedForm == originalCompanion.evolvedForm)
    }
}