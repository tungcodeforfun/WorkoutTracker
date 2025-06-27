//
//  ModernOnboardingView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernOnboardingView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var username = ""
    @State private var trainerName = ""
    @State private var currentPage = 0
    @State private var animationAmount = 1.0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Theme.Colors.accent.opacity(0.1), Theme.Colors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    UserInfoPage(username: $username, trainerName: $trainerName)
                        .tag(1)
                    
                    ReadyPage(username: username, trainerName: trainerName, viewModel: viewModel)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                HStack(spacing: Theme.Spacing.xSmall) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(currentPage == index ? Theme.Colors.accent : Theme.Colors.secondaryText.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(currentPage == index ? 1.2 : 1.0)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, Theme.Spacing.xLarge)
            }
        }
    }
}

struct WelcomePage: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Theme.gradient.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(Theme.Colors.accent)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(spacing: Theme.Spacing.medium) {
                Text("Pokemon")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                + Text(" Workout")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.accent)
                
                Text("Transform your workouts into\nan epic Pokemon adventure")
                    .font(.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            VStack(spacing: Theme.Spacing.medium) {
                FeatureRow(icon: "sparkles", text: "Catch & train Pokemon", color: .purple)
                FeatureRow(icon: "figure.run", text: "Track real workouts", color: .blue)
                FeatureRow(icon: "trophy.fill", text: "Earn badges & rewards", color: .orange)
            }
            
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xLarge)
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

struct UserInfoPage: View {
    @Binding var username: String
    @Binding var trainerName: String
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, trainerName
    }
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()
            
            VStack(spacing: Theme.Spacing.medium) {
                Text("Let's get to know you")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Choose your trainer identity")
                    .font(.body)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
            
            VStack(spacing: Theme.Spacing.large) {
                ModernTextField(
                    placeholder: "Username",
                    text: $username,
                    icon: "person.fill"
                )
                .focused($focusedField, equals: .username)
                
                ModernTextField(
                    placeholder: "Trainer Name",
                    text: $trainerName,
                    icon: "star.fill"
                )
                .focused($focusedField, equals: .trainerName)
            }
            .padding(.vertical, Theme.Spacing.xLarge)
            
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xLarge)
        .onAppear {
            focusedField = .username
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

struct ReadyPage: View {
    let username: String
    let trainerName: String
    @ObservedObject var viewModel: AppViewModel
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()
            
            VStack(spacing: Theme.Spacing.large) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(Theme.Colors.success)
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .onAppear {
                        withAnimation(.spring()) {
                            isAnimating = true
                        }
                    }
                
                Text("All set, \(trainerName)!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Ready to begin your\nPokemon fitness journey?")
                    .font(.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.createUser(username: username, trainerName: trainerName)
            }) {
                HStack {
                    Text("Choose Your Starter")
                    Image(systemName: "arrow.right")
                }
            }
            .primaryButtonStyle()
            .disabled(username.isEmpty || trainerName.isEmpty)
            
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.xLarge)
    }
}

#Preview {
    ModernOnboardingView(viewModel: AppViewModel())
}