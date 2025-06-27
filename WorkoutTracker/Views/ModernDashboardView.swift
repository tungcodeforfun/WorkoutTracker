//
//  ModernDashboardView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernDashboardView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var greeting = "Good Morning"
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.large) {
                        if let user = viewModel.currentUser {
                            HeaderSection(user: user, greeting: greeting)
                                .padding(.horizontal)
                            
                            if let activePokemon = user.activePokemon {
                                ModernPokemonCard(pokemon: activePokemon)
                                    .padding(.horizontal)
                            }
                            
                            QuickActionsSection(viewModel: viewModel)
                                .padding(.horizontal)
                            
                            StatsOverview(user: user)
                            
                            RecentActivitySection(user: user)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            #if os(iOS)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            #endif
            .onAppear { updateGreeting() }
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        greeting = hour < 12 ? "Good Morning" :
                   hour < 18 ? "Good Afternoon" : "Good Evening"
    }
}

struct HeaderSection: View {
    let user: User
    let greeting: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text(greeting)
                    .font(.title2)
                    .foregroundColor(Theme.Colors.secondaryText)
                
                Text(user.trainerName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.gradient)
                    .frame(width: 56, height: 56)
                
                Text(String(user.trainerName.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .padding(.top)
    }
}

struct ModernPokemonCard: View {
    let pokemon: Pokemon
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                    Text("Active Pokemon")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                        .textCase(.uppercase)
                    
                    Text(pokemon.nickname ?? pokemon.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    HStack(spacing: Theme.Spacing.xSmall) {
                        PillTag(text: "Lv.\(pokemon.level)", color: pokemon.type.color)
                        PillTag(text: pokemon.type.rawValue, color: pokemon.type.color.opacity(0.2), textColor: pokemon.type.color)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [pokemon.type.color.opacity(0.3), pokemon.type.color.opacity(0.1)],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                    
                    Text(String(pokemon.name.prefix(1)))
                        .font(.system(size: 60, weight: .bold, design: .rounded))
                        .foregroundColor(pokemon.type.color)
                }
            }
            .padding(Theme.Spacing.large)
            
            VStack(spacing: Theme.Spacing.small) {
                HStack {
                    Text("Experience")
                        .font(.caption)
                        .foregroundColor(Theme.Colors.secondaryText)
                    
                    Spacer()
                    
                    Text("\(pokemon.experience)/\(pokemon.experienceForNextLevel()) XP")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.Colors.primaryText)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .fill(Theme.Colors.background)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .fill(
                                LinearGradient(
                                    colors: [pokemon.type.color, pokemon.type.color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * CGFloat(pokemon.experience) / CGFloat(pokemon.experienceForNextLevel()),
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
            .padding(Theme.Spacing.large)
            .background(Theme.Colors.background.opacity(0.5))
        }
        .modernCard()
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct PillTag: View {
    let text: String
    let color: Color
    var textColor: Color = .white
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(textColor)
            .padding(.horizontal, Theme.Spacing.small)
            .padding(.vertical, Theme.Spacing.xxSmall)
            .background(
                Capsule()
                    .fill(color)
            )
    }
}

struct QuickActionsSection: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            QuickActionButton(
                icon: "figure.run",
                title: "Start Workout",
                color: Theme.Colors.accent
            ) {
                viewModel.selectedTab = 1
            }
            
            QuickActionButton(
                icon: "trophy.fill",
                title: "View Progress",
                color: Theme.Colors.warning
            ) {
                viewModel.selectedTab = 3
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: Theme.Spacing.small) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(color)
                    )
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.primaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(Theme.Colors.surface)
                    .shadow(color: Theme.cardShadow, radius: 6, x: 0, y: 2)
            )
        }
    }
}

struct StatsOverview: View {
    let user: User
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.medium) {
                StatCard(
                    value: "\(user.workouts.count)",
                    label: "Workouts",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    value: "\(user.totalExperience)",
                    label: "Total XP",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    value: "\(user.pokemon.count)",
                    label: "Pokemon",
                    icon: "sparkles",
                    color: .purple
                )
                
                StatCard(
                    value: "\(user.badges.count)",
                    label: "Badges",
                    icon: "medal.fill",
                    color: .blue
                )
            }
            .padding(.horizontal)
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text(label)
                .font(.caption)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .frame(width: 100)
        .padding(.vertical, Theme.Spacing.large)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .fill(Theme.Colors.surface)
                .shadow(color: Theme.cardShadow, radius: 6, x: 0, y: 2)
        )
    }
}

struct RecentActivitySection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Recent Activity")
                .font(.headline)
                .foregroundColor(Theme.Colors.primaryText)
            
            if user.workouts.isEmpty {
                EmptyStateCard(
                    icon: "figure.run",
                    message: "No workouts yet",
                    submessage: "Start your first workout to see progress here!"
                )
            } else {
                VStack(spacing: Theme.Spacing.small) {
                    ForEach(user.workouts.suffix(3)) { workout in
                        ModernWorkoutRow(workout: workout)
                    }
                }
            }
        }
    }
}

struct ModernWorkoutRow: View {
    let workout: Workout
    
    var body: some View {
        HStack {
            Circle()
                .fill(Theme.Colors.accent.opacity(0.2))
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "figure.run")
                        .foregroundColor(Theme.Colors.accent)
                )
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxSmall) {
                Text(workout.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("\(workout.exercises.count) exercises • \(formatDuration(workout.totalDuration))")
                    .font(.caption)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            Spacer()
            
            Text("+\(workout.totalExperience)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(Theme.Colors.success)
            
            Text("XP")
                .font(.caption)
                .foregroundColor(Theme.Colors.success)
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.background)
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

struct EmptyStateCard: View {
    let icon: String
    let message: String
    let submessage: String
    
    var body: some View {
        VStack(spacing: Theme.Spacing.small) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundColor(Theme.Colors.secondaryText)
            
            Text(message)
                .font(.headline)
                .foregroundColor(Theme.Colors.primaryText)
            
            Text(submessage)
                .font(.caption)
                .foregroundColor(Theme.Colors.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.xLarge)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .fill(Theme.Colors.background)
        )
    }
}

#Preview {
    ModernDashboardView(viewModel: AppViewModel())
}