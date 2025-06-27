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
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Dark gradient background like onboarding
            LinearGradient(
                colors: [Color(red: 0.2, green: 0.3, blue: 0.2), Color(red: 0.3, green: 0.6, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom header
                HStack {
                    Text("Profile")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : -20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
                
                ScrollView {
                    if let user = viewModel.currentUser {
                        VStack(spacing: 32) {
                            // Profile Header
                            ProfileHeader(user: user)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 30)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: showContent)
                            
                            // Stats Section
                            StatsSection(user: user)
                                .opacity(showContent ? 1 : 0)
                                .offset(x: showContent ? 0 : -50)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showContent)
                            
                            // Badges Section
                            if !user.badges.isEmpty {
                                AllBadgesSection(badges: user.badges)
                                    .opacity(showContent ? 1 : 0)
                                    .offset(x: showContent ? 0 : 50)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showContent)
                            }
                            
                            // Workout History
                            WorkoutHistorySection(workouts: user.workouts)
                                .opacity(showContent ? 1 : 0)
                                .offset(y: showContent ? 0 : 30)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: showContent)
                            
                            // Reset Button
                            Button(action: { showingResetAlert = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "trash.fill")
                                    Text("Reset Account")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.3))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                        )
                                )
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .opacity(showContent ? 1 : 0)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(1.0), value: showContent)
                        }
                        .padding(.vertical, 20)
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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showContent = true
            }
        }
    }
}

struct ProfileHeader: View {
    let user: User
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Profile Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(String(user.trainerName.prefix(1)))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
            .onAppear { isAnimating = true }
            
            VStack(spacing: 12) {
                Text(user.trainerName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("@\(user.username)")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Text("Trainer since \(user.joinDate, style: .date)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
}

struct StatsSection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistics")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                StatItem(icon: "figure.run", title: "Workouts", value: "\(user.workouts.count)", color: .blue)
                StatItem(icon: "sparkles", title: "Pokemon", value: "\(user.pokemon.count)", color: .purple)
                StatItem(icon: "trophy.fill", title: "Badges", value: "\(user.badges.count)", color: .orange)
                StatItem(icon: "flame.fill", title: "Total XP", value: "\(user.pokemon.reduce(0) { $0 + $1.experience })", color: .red)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct StatItem: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct AllBadgesSection: View {
    let badges: [Badge]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(badges) { badge in
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.yellow)
                            }
                            
                            VStack(spacing: 4) {
                                Text(badge.type.rawValue)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Text(badge.earnedDate, style: .date)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .frame(width: 100)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct WorkoutHistorySection: View {
    let workouts: [Workout]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Workouts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(workouts.count) total")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            if workouts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No workouts yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Start your first workout to see your history here")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(workouts.prefix(5)) { workout in
                        WorkoutHistoryRow(workout: workout)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct WorkoutHistoryRow: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("\(workout.exercises.count) exercises")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("\(Int(workout.totalDuration/60)) min")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                        Text("+\(workout.totalExperience) XP")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Text(workout.date, style: .date)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    ProfileView(viewModel: AppViewModel())
}