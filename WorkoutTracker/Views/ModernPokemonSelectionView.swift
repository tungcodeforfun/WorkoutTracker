//
//  ModernPokemonSelectionView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernPokemonSelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedPokemon: Pokemon?
    @State private var showingDetails = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.large) {
                HeaderView()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.medium) {
                        ForEach(starterPokemon) { pokemon in
                            ModernPokemonSelectionCard(
                                pokemon: pokemon,
                                isSelected: selectedPokemon?.id == pokemon.id
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedPokemon = pokemon
                                    showingDetails = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if let selected = selectedPokemon {
                    Button(action: {
                        viewModel.selectStarterPokemon(selected)
                    }) {
                        HStack {
                            Text("I choose you, \(selected.name)!")
                            Image(systemName: "sparkles")
                        }
                    }
                    .primaryButtonStyle()
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingDetails) {
            if let pokemon = selectedPokemon {
                PokemonDetailSheet(pokemon: pokemon) {
                    viewModel.selectStarterPokemon(pokemon)
                }
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text("Choose Your Partner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text("Your Pokemon will grow stronger with every workout")
                .font(.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

struct ModernPokemonSelectionCard: View {
    let pokemon: Pokemon
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(
                        LinearGradient(
                            colors: [
                                pokemon.type.color.opacity(0.2),
                                pokemon.type.color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(spacing: Theme.Spacing.small) {
                    Text(String(pokemon.name.prefix(1)))
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(pokemon.type.color)
                        .scaleEffect(1.0)
                    
                    Text(pokemon.name)
                        .font(.headline)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Text(pokemon.type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(pokemon.type.color)
                        )
                }
                .padding(.vertical, Theme.Spacing.large)
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .stroke(
                        isSelected ? pokemon.type.color : Color.clear,
                        lineWidth: 3
                    )
            )
            .shadow(
                color: isSelected ? pokemon.type.color.opacity(0.3) : Theme.cardShadow,
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

struct PokemonDetailSheet: View {
    let pokemon: Pokemon
    let onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [pokemon.type.color.opacity(0.3), pokemon.type.color.opacity(0.1)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 250)
                
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                    }
                    .padding()
                    
                    Text(String(pokemon.name.prefix(1)))
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(pokemon.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: Theme.Spacing.large) {
                HStack(spacing: Theme.Spacing.small) {
                    Text(pokemon.type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(pokemon.type.color)
                        )
                    if let evolutionLevel = pokemon.evolutionLevel {
                        Text("Evolves at Lv.\(evolutionLevel)")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Theme.Colors.accent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Theme.Colors.accent.opacity(0.2))
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                    InfoRow(title: "Type", value: pokemon.type.rawValue, color: pokemon.type.color)
                    InfoRow(title: "Base HP", value: "\(pokemon.baseStats.hp)", color: .red)
                    InfoRow(title: "Base Attack", value: "\(pokemon.baseStats.attack)", color: .orange)
                    InfoRow(title: "Base Defense", value: "\(pokemon.baseStats.defense)", color: .blue)
                    InfoRow(title: "Base Speed", value: "\(pokemon.baseStats.speed)", color: .green)
                    
                    if let evolvedForm = pokemon.evolvedForm {
                        InfoRow(title: "Evolution", value: evolvedForm, color: .purple)
                    }
                }
                .padding(.horizontal)
                
                Button(action: {
                    onSelect()
                    dismiss()
                }) {
                    HStack {
                        Text("Choose \(pokemon.name)")
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                .primaryButtonStyle()
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical, Theme.Spacing.large)
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Label(title, systemImage: "circle.fill")
                .font(.subheadline)
                .foregroundColor(Theme.Colors.secondaryText)
                .labelStyle(IconWithTextLabelStyle(iconColor: color))
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(Theme.Colors.primaryText)
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}

struct IconWithTextLabelStyle: LabelStyle {
    let iconColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: Theme.Spacing.xSmall) {
            configuration.icon
                .foregroundColor(iconColor)
                .font(.caption)
            configuration.title
        }
    }
}

#Preview {
    ModernPokemonSelectionView(viewModel: AppViewModel())
}