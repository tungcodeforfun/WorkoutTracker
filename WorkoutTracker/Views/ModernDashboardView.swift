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
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Dark gradient background like onboarding
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.3, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    if let user = viewModel.currentUser {
                        // Header Section
                        VStack(spacing: 24) {
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(greeting)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Text(user.trainerName)
                                        .font(.system(size: 32, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                }
                                
                                Spacer()
                                
                                // Profile avatar
                                ZStack {
                                    Circle()
                                        .fill(LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 60, height: 60)
                                    
                                    Text(String(user.trainerName.prefix(1)))
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : -20)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        // Active Companion Card
                        if let activeCompanion = user.activeCompanion {
                            ModernCompanionCard(companion: activeCompanion)
                                .padding(.horizontal, 24)
                                .opacity(showContent ? 1 : 0)
                                .offset(x: showContent ? 0 : -50)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: showContent)
                        }
                        
                        // Quick Actions
                        QuickActionsSection(viewModel: viewModel)
                            .padding(.horizontal, 24)
                            .opacity(showContent ? 1 : 0)
                            .offset(x: showContent ? 0 : 50)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showContent)
                        
                        // Stats Overview
                        StatsOverview(user: user)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showContent)
                        
                        // Recent Activity
                        RecentActivitySection(user: user)
                            .padding(.horizontal, 24)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 30)
                            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: showContent)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            updateGreeting()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showContent = true
            }
        }
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        default:
            greeting = "Good Evening"
        }
    }
}

struct ModernCompanionCard: View {
    let companion: Companion
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Active Companion")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(companion.nickname ?? companion.name)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Text("Level \(companion.level)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(companion.type.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .stroke(companion.type.color.opacity(0.3), lineWidth: 1)
                            )
                        
                        Text(companion.type.rawValue)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                Spacer()
                
                // Companion Avatar
                ZStack {
                    Circle()
                        .stroke(companion.type.color.opacity(0.4), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                    
                    Text(String(companion.name.prefix(1)))
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(companion.type.color)
                }
            }
            .padding(24)
            
            // XP Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("XP Progress")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(companion.experience)/\(companion.experienceForNextLevel())")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ProgressBar(
                    value: Double(companion.experience),
                    maxValue: Double(companion.experienceForNextLevel()),
                    color: companion.type.color
                )
                .frame(height: 8)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.clear, lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .onAppear { 
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true 
            }
        }
    }
}

struct QuickActionsSection: View {
    @ObservedObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                QuickActionButton(icon: "figure.run", title: "Start Workout", color: .blue) {
                    viewModel.selectedTab = 1
                }
                
                QuickActionButton(icon: "sparkles", title: "View Companions", color: .purple) {
                    viewModel.selectedTab = 2
                }
            }
        }
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.clear, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onPressGesture(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
    }
}

struct StatsOverview: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Progress")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    StatCard(icon: "figure.run", title: "Workouts", value: "\(user.workouts.count)", color: .blue)
                    StatCard(icon: "sparkles", title: "Companions", value: "\(user.companions.count)", color: .purple)
                    StatCard(icon: "trophy.fill", title: "Badges", value: "\(user.badges.count)", color: .orange)
                    StatCard(icon: "flame.fill", title: "Total XP", value: "\(user.companions.reduce(0) { $0 + $1.experience })", color: .red)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .frame(width: 100, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.clear, lineWidth: 1)
                )
        )
    }
}

struct RecentActivitySection: View {
    let user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            if user.workouts.isEmpty {
                EmptyStateCard()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(user.workouts.prefix(3)) { workout in
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
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(workout.exercises.count) exercises")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(workout.date, style: .date)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("+\(workout.totalExperience) XP")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
                
                Text("\(Int(workout.totalDuration/60)) min")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.clear, lineWidth: 1)
                )
        )
    }
}

struct EmptyStateCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No workouts yet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Start your first workout to see your activity here")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.clear, lineWidth: 1)
                )
        )
    }
}

extension View {
    func onPressGesture(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

struct ProgressBar: View {
    let value: Double
    let maxValue: Double
    let color: Color
    
    private var progress: Double {
        guard maxValue > 0 else { return 0 }
        return min(max(0, value / maxValue), 1.0)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                .frame(height: 8)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(LinearGradient(
                    colors: [color, color.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .frame(width: 200 * progress, height: 8)
        }
        .frame(width: 200, height: 8)
    }
}

#Preview {
    ModernDashboardView(viewModel: AppViewModel())
}