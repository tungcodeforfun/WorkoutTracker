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
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Dark gradient background like onboarding
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.2, blue: 0.35), Color(red: 0.3, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("My Pokemon")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let user = viewModel.currentUser {
                        Text("\(user.pokemon.count)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.clear)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
                
                ScrollView {
                    if let user = viewModel.currentUser {
                        if user.pokemon.isEmpty {
                            EmptyPokemonState()
                                .padding(.top, 60)
                                .opacity(showContent ? 1 : 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: showContent)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(Array(user.pokemon.enumerated()), id: \.element.id) { index, pokemon in
                                    PokemonDetailCard(
                                        pokemon: pokemon,
                                        isActive: pokemon.id == user.activePokemonId
                                    )
                                    .onTapGesture {
                                        selectedPokemon = pokemon
                                    }
                                    .opacity(showContent ? 1 : 0)
                                    .offset(y: showContent ? 0 : 30)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.1), value: showContent)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedPokemon) { pokemon in
            PokemonManagementSheet(pokemon: pokemon, viewModel: viewModel)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showContent = true
            }
        }
    }
}

struct PokemonDetailCard: View {
    let pokemon: Pokemon
    let isActive: Bool
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Active badge
            if isActive {
                HStack {
                    Text("ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [Color.green, Color.blue], startPoint: .leading, endPoint: .trailing))
                        )
                    
                    Spacer()
                }
            } else {
                Spacer()
                    .frame(height: 18)
            }
            
            // Pokemon avatar
            ZStack {
                Circle()
                    .fill(pokemon.type.color.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(String(pokemon.name.prefix(1)))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(pokemon.type.color)
            }
            
            VStack(spacing: 8) {
                Text(pokemon.nickname ?? pokemon.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("Level \(pokemon.level)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(pokemon.type.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(pokemon.type.color.opacity(0.2))
                        )
                    
                    Text(pokemon.type.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.clear)
                        )
                }
            }
            
            // XP Progress
            VStack(spacing: 6) {
                HStack {
                    Text("XP")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(pokemon.experience)/\(pokemon.experienceForNextLevel())")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                MiniProgressBar(
                    value: Double(pokemon.experience),
                    maxValue: Double(pokemon.experienceForNextLevel()),
                    color: pokemon.type.color
                )
            }
        }
        .padding(16)
        .frame(height: 240)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.3), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isActive ? 2 : 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear { isAnimating = true }
    }
}

struct EmptyPokemonState: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text("No Pokemon Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Complete your first workout to\ncatch your starter Pokemon!")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
    }
}

struct PokemonManagementSheet: View {
    let pokemon: Pokemon
    @ObservedObject var viewModel: AppViewModel
    @Environment(\.dismiss) var dismiss
    @State private var nickname = ""
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.2, blue: 0.35), Color(red: 0.3, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("Pokemon Details")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        if !nickname.isEmpty {
                            viewModel.updatePokemonNickname(pokemon.id, nickname: nickname)
                        }
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
                
                // Pokemon Display
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(pokemon.type.color.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        Text(String(pokemon.name.prefix(1)))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(pokemon.type.color)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
                    
                    VStack(spacing: 16) {
                        Text(pokemon.nickname ?? pokemon.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            StatRow(label: "Level", value: "\(pokemon.level)", color: pokemon.type.color)
                            StatRow(label: "Type", value: pokemon.type.rawValue, color: pokemon.type.color)
                        }
                        
                        StatRow(label: "Experience", value: "\(pokemon.experience)/\(pokemon.experienceForNextLevel())", color: pokemon.type.color)
                    }
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showContent)
                }
                
                // Nickname Input
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nickname")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    TextField(pokemon.name, text: $nickname)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showContent)
                
                // Action Buttons
                VStack(spacing: 16) {
                    if viewModel.currentUser?.activePokemonId != pokemon.id {
                        Button(action: {
                            viewModel.setActivePokemon(pokemon.id)
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "star.fill")
                                Text("Set as Active")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: showContent)
                
                Spacer()
            }
        }
        .onAppear {
            nickname = pokemon.nickname ?? ""
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct MiniProgressBar: View {
    let value: Double
    let maxValue: Double
    let color: Color
    
    private var progress: Double {
        guard maxValue > 0 else { return 0 }
        return min(max(0, value / maxValue), 1.0)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
                .stroke(color.opacity(0.3), lineWidth: 1)
                .frame(height: 6)
            
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
                .frame(width: 140 * progress, height: 6)
        }
        .frame(width: 140, height: 6)
    }
}

#Preview {
    PokemonListView(viewModel: AppViewModel())
}