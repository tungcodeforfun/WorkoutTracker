//
//  ModernCompanionSelectionView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernCompanionSelectionView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedCompanion: Companion?
    @State private var showingDetails = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.2, blue: 0.35), Color(red: 0.3, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.large) {
                CompanionHeaderView()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.medium) {
                        ForEach(starterCompanions) { companion in
                            ModernCompanionSelectionCard(
                                companion: companion,
                                isSelected: selectedCompanion?.id == companion.id
                            )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    selectedCompanion = companion
                                    showingDetails = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if let selected = selectedCompanion {
                    Button(action: {
                        viewModel.selectStarterCompanion(selected)
                    }) {
                        HStack {
                            Text("Choose \(selected.name)!")
                            Image(systemName: "sparkles")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingDetails) {
            if let companion = selectedCompanion {
                CompanionDetailSheet(companion: companion) {
                    viewModel.selectStarterCompanion(companion)
                }
            }
        }
    }
}

struct CompanionHeaderView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text("Choose Your Companion")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Your companion will grow stronger with every workout")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

struct ModernCompanionSelectionCard: View {
    let companion: Companion
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        companion.type.color.opacity(0.4),
                                        companion.type.color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                VStack(spacing: Theme.Spacing.small) {
                    Text(String(companion.name.prefix(1)))
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                        .foregroundColor(companion.type.color)
                        .scaleEffect(1.0)
                    
                    Text(companion.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(companion.type.rawValue)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(companion.type.color)
                        )
                }
                .padding(.vertical, Theme.Spacing.large)
            }
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .stroke(
                        isSelected ? companion.type.color : Color.clear,
                        lineWidth: 3
                    )
            )
            .shadow(
                color: isSelected ? companion.type.color.opacity(0.3) : Color.black.opacity(0.2),
                radius: isSelected ? 12 : 6,
                x: 0,
                y: isSelected ? 4 : 2
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
}

struct CompanionDetailSheet: View {
    let companion: Companion
    let onSelect: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.15, green: 0.2, blue: 0.35), Color(red: 0.3, green: 0.4, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header section
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
                    
                    Text(String(companion.name.prefix(1)))
                        .font(.system(size: 80, weight: .bold, design: .rounded))
                        .foregroundColor(companion.type.color)
                    
                    Text(companion.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(height: 250)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        HStack(spacing: Theme.Spacing.small) {
                            Text(companion.type.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(companion.type.color)
                                )
                            if let evolutionLevel = companion.evolutionLevel {
                                Text("Evolves at Lv.\(evolutionLevel)")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.2))
                                    )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            CompanionInfoRow(title: "Type", value: companion.type.rawValue, color: companion.type.color)
                            CompanionInfoRow(title: "Base HP", value: "\(companion.baseStats.hp)", color: .red)
                            CompanionInfoRow(title: "Base Attack", value: "\(companion.baseStats.attack)", color: .orange)
                            CompanionInfoRow(title: "Base Defense", value: "\(companion.baseStats.defense)", color: .blue)
                            CompanionInfoRow(title: "Base Speed", value: "\(companion.baseStats.speed)", color: .green)
                            
                            if let evolvedForm = companion.evolvedForm {
                                CompanionInfoRow(title: "Evolution", value: evolvedForm, color: .purple)
                            }
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            onSelect()
                            dismiss()
                        }) {
                            HStack {
                                Text("Choose \(companion.name)")
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.vertical, Theme.Spacing.large)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: showContent)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
    }
}

struct CompanionInfoRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: Theme.Spacing.xSmall) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.vertical, Theme.Spacing.xSmall)
    }
}

#Preview {
    ModernCompanionSelectionView(viewModel: AppViewModel())
}