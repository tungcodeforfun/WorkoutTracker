//
//  PokemonListView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct PokemonListView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedPokemon: Pokemon?
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let user = viewModel.currentUser {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(user.pokemon) { pokemon in
                            PokemonDetailCard(
                                pokemon: pokemon,
                                isActive: pokemon.id == user.activePokemonId
                            )
                            .onTapGesture {
                                selectedPokemon = pokemon
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Pokemon")
            .sheet(item: $selectedPokemon) { pokemon in
                PokemonManagementSheet(pokemon: pokemon, viewModel: viewModel)
            }
        }
    }
}

struct PokemonDetailCard: View {
    let pokemon: Pokemon
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isActive {
                Text("ACTIVE")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green)
                    )
            }
            
            ZStack {
                Circle()
                    .fill(pokemon.type.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Text(String(pokemon.name.prefix(2)).uppercased())
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(pokemon.type.color)
            }
            
            Text(pokemon.nickname ?? pokemon.name)
                .font(.headline)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Text("Lv.\(pokemon.level)")
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(pokemon.type.rawValue)
                    .font(.caption)
                    .foregroundColor(pokemon.type.color)
            }
            
            ProgressView(value: Double(pokemon.experience),
                        total: Double(pokemon.experienceForNextLevel()))
                .tint(pokemon.type.color)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isActive ? Color.green : Color.clear, lineWidth: 2)
                )
        )
    }
}

struct PokemonManagementSheet: View {
    let pokemon: Pokemon
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var newNickname = ""
    @State private var showingNicknameField = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(pokemon.type.color.opacity(0.3))
                            .frame(width: 150, height: 150)
                        
                        Text(String(pokemon.name.prefix(2)).uppercased())
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(pokemon.type.color)
                    }
                    
                    VStack(spacing: 8) {
                        Text(pokemon.nickname ?? pokemon.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if pokemon.nickname == nil && !showingNicknameField {
                            Button("Give Nickname") {
                                showingNicknameField = true
                                newNickname = ""
                            }
                            .font(.caption)
                        }
                        
                        if showingNicknameField {
                            HStack {
                                TextField("Nickname", text: $newNickname)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Save") {
                                    saveNickname()
                                }
                                .disabled(newNickname.isEmpty)
                            }
                            .padding(.horizontal)
                        }
                        
                        Text("Level \(pokemon.level)")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 16) {
                        StatRow(title: "Type", value: pokemon.type.rawValue, color: pokemon.type.color)
                        StatRow(title: "HP", value: "\(pokemon.currentStats.hp)", color: .red)
                        StatRow(title: "Attack", value: "\(pokemon.currentStats.attack)", color: .orange)
                        StatRow(title: "Defense", value: "\(pokemon.currentStats.defense)", color: .blue)
                        StatRow(title: "Speed", value: "\(pokemon.currentStats.speed)", color: .green)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    VStack(spacing: 8) {
                        Text("Experience")
                            .font(.headline)
                        
                        ProgressView(value: Double(pokemon.experience),
                                   total: Double(pokemon.experienceForNextLevel()))
                            .tint(pokemon.type.color)
                            .scaleEffect(y: 2)
                        
                        Text("\(pokemon.experience) / \(pokemon.experienceForNextLevel()) XP")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    if pokemon.id != viewModel.currentUser?.activePokemonId {
                        Button(action: makeActive) {
                            Text("Make Active")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(pokemon.type.color)
                                )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Pokemon Details")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
    
    private func saveNickname() {
        guard let index = viewModel.currentUser?.pokemon.firstIndex(where: { $0.id == pokemon.id }) else { return }
        viewModel.currentUser?.pokemon[index].nickname = newNickname
        showingNicknameField = false
        viewModel.saveUser()
    }
    
    private func makeActive() {
        viewModel.currentUser?.activePokemonId = pokemon.id
        viewModel.saveUser()
        dismiss()
    }
}

struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: "circle.fill")
                .foregroundColor(color)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    PokemonListView(viewModel: AppViewModel())
}