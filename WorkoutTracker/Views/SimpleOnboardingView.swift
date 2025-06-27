//
//  SimpleOnboardingView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct SimpleOnboardingView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var username = ""
    @State private var trainerName = ""
    @State private var animationAmount = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LinearGradient(
                    colors: [Theme.Colors.accent.opacity(0.1), Theme.Colors.background],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xLarge) {
                        Spacer(minLength: 60)
                        
                        // App Icon and Title
                        VStack(spacing: Theme.Spacing.large) {
                            ZStack {
                                Circle()
                                    .fill(Theme.gradient.opacity(0.2))
                                    .frame(width: 140, height: 140)
                                    .scaleEffect(animationAmount)
                                
                                Image(systemName: "figure.run.circle.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(Theme.Colors.accent)
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                                    animationAmount = 1.1
                                }
                            }
                            
                            VStack(spacing: Theme.Spacing.small) {
                                HStack(spacing: 4) {
                                    Text("Pokemon")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.primaryText)
                                    
                                    Text("Workout")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.Colors.accent)
                                }
                                
                                Text("Transform your workouts into an epic Pokemon adventure")
                                    .font(.body)
                                    .foregroundColor(Theme.Colors.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Features
                        VStack(spacing: Theme.Spacing.medium) {
                            FeatureRow(icon: "sparkles", text: "Catch & train Pokemon", color: .purple)
                            FeatureRow(icon: "figure.run", text: "Track real workouts", color: .blue)
                            FeatureRow(icon: "trophy.fill", text: "Earn badges & rewards", color: .orange)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                        
                        // User Input
                        VStack(spacing: Theme.Spacing.large) {
                            Text("Let's get started!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Colors.primaryText)
                            
                            VStack(spacing: Theme.Spacing.medium) {
                                ModernTextField(
                                    placeholder: "Username",
                                    text: $username,
                                    icon: "person.fill"
                                )
                                
                                ModernTextField(
                                    placeholder: "Trainer Name",
                                    text: $trainerName,
                                    icon: "star.fill"
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Start Button
                        Button(action: {
                            print("Creating user: \(username), \(trainerName)")
                            viewModel.createUser(username: username, trainerName: trainerName)
                        }) {
                            HStack {
                                Text("Choose Your Starter Pokemon")
                                Image(systemName: "arrow.right")
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(username.isEmpty || trainerName.isEmpty)
                        .padding(.horizontal)
                        
                        // Debug: Reset button
                        Button("Reset User Data (Debug)") {
                            viewModel.resetUser()
                        }
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top)
                        
                        Spacer(minLength: 60)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.Colors.primaryText)
            
            Spacer()
        }
    }
}

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .foregroundColor(Theme.Colors.accent)
                .frame(width: 24)
            
            TextField(placeholder, text: $text)
                .font(.body)
        }
        .padding(Theme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.surface)
                .shadow(color: Theme.cardShadow, radius: 4, x: 0, y: 2)
        )
    }
}

#Preview {
    SimpleOnboardingView(viewModel: AppViewModel())
}