//
//  ProfileView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showingResetAlert = false
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Theme.Colors.primaryText)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, Theme.Spacing.medium)
                .padding(.bottom, Theme.Spacing.small)
                
                ScrollView {
                    if let user = viewModel.currentUser {
                        VStack(spacing: 20) {
                            ProfileHeader(user: user)
                            
                            StatsSection(user: user)
                            
                            if !user.badges.isEmpty {
                                AllBadgesSection(badges: user.badges)
                            }
                            
                            WorkoutHistorySection(workouts: user.workouts)
                            
                            Button(action: { showingResetAlert = true }) {
                                Text("Reset Account")
                                    .foregroundColor(.red)
                            }
                            .padding(.top, 20)
                        }
                        .padding()
                    }
                }
            }
        }
        .alert("Reset Account", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetUser()
            }
        } message: {
            Text("This will delete all your data including Pokemon, workouts, and badges. This cannot be undone.")
        }
    }
}

struct ProfileHeader: View {
    let user: User
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 8) {
                Text(user.trainerName)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Label("Level \(user.level)", systemImage: "star.fill")
                        .foregroundColor(.orange)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(user.totalExperience) XP")
                        .foregroundColor(.secondary)
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct StatsSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            VStack(spacing: 12) {
                StatItem(icon: "calendar", title: "Member Since", value: user.joinDate.formatted(date: .abbreviated, time: .omitted))
                StatItem(icon: "figure.run", title: "Total Workouts", value: "\(user.workouts.count)")
                StatItem(icon: "sparkles", title: "Pokemon Caught", value: "\(user.pokemon.count)")
                StatItem(icon: "medal.fill", title: "Badges Earned", value: "\(user.badges.count)")
                
                if let averageXP = calculateAverageXP(workouts: user.workouts) {
                    StatItem(icon: "chart.bar.fill", title: "Average XP/Workout", value: "\(averageXP)")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
    
    private func calculateAverageXP(workouts: [Workout]) -> Int? {
        guard !workouts.isEmpty else { return nil }
        let totalXP = workouts.reduce(0) { $0 + $1.totalExperience }
        return totalXP / workouts.count
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }
}

struct AllBadgesSection: View {
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Badges")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(badges) { badge in
                    VStack(spacing: 8) {
                        Image(systemName: badge.type.icon)
                            .font(.title2)
                            .foregroundColor(.orange)
                        
                        Text(badge.type.rawValue)
                            .font(.caption2)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct WorkoutHistorySection: View {
    let workouts: [Workout]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Workout History")
                    .font(.headline)
                
                Spacer()
                
                Text("\(workouts.count) total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if workouts.isEmpty {
                Text("No workouts yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                ForEach(workouts.sorted(by: { $0.date > $1.date }).prefix(10)) { workout in
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(workout.date, style: .date)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("+\(workout.totalExperience) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("\(workout.exercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(formatDuration(workout.totalDuration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}

#Preview {
    ProfileView(viewModel: AppViewModel())
}