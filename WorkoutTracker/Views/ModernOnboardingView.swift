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
    
    var body: some View {
        ZStack {
            // Dynamic gradient background based on current page
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    WelcomePage()
                        .tag(0)
                    
                    UserInfoPage(username: $username, trainerName: $trainerName, currentPage: $currentPage)
                        .tag(1)
                    
                    ReadyPage(username: username, trainerName: trainerName, viewModel: viewModel)
                        .tag(2)
                }
                #if os(iOS)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                #endif
                
                // Modern page indicator
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 24 : 8, height: 4)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
                    }
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private var gradientColors: [Color] {
        switch currentPage {
        case 0:
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.3, blue: 0.5)]
        case 1:
            return [Color(red: 0.15, green: 0.2, blue: 0.35), Color(red: 0.3, green: 0.4, blue: 0.6)]
        case 2:
            return [Color(red: 0.2, green: 0.3, blue: 0.2), Color(red: 0.3, green: 0.6, blue: 0.4)]
        default:
            return [Color(red: 0.1, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.3, blue: 0.5)]
        }
    }
}

struct WelcomePage: View {
    @State private var isAnimating = false
    @State private var showFeatures = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Hero section
            VStack(spacing: 24) {
                ZStack {
                    // Animated background circles
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 180, height: 180)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 240, height: 240)
                        .scaleEffect(isAnimating ? 0.8 : 1.2)
                        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: isAnimating)
                    
                    // Main icon
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "figure.run")
                            .font(.system(size: 60, weight: .light))
                            .foregroundColor(.white)
                    }
                }
                .onAppear { isAnimating = true }
                
                VStack(spacing: 16) {
                    // App title with modern typography
                    HStack(spacing: 8) {
                        Text("PokeFit")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.yellow)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                    }
                    
                    Text("Turn every workout into\na Pokemon adventure")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            
            Spacer()
            
            // Feature highlights
            VStack(spacing: 20) {
                ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                    ModernFeatureRow(
                        icon: feature.icon,
                        title: feature.title,
                        description: feature.description,
                        color: feature.color
                    )
                    .opacity(showFeatures ? 1 : 0)
                    .offset(x: showFeatures ? 0 : 50)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(Double(index) * 0.2), value: showFeatures)
                }
            }
            .padding(.horizontal, 24)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showFeatures = true
                }
            }
            
            Spacer()
            
            // Swipe hint
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text("Swipe to continue")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(isAnimating ? 0.7 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 32)
    }
    
    private let features = [
        (icon: "figure.strengthtraining.traditional", title: "Real Workouts", description: "Track actual exercises & progress", color: Color.blue),
        (icon: "sparkles", title: "Pokemon Evolution", description: "Level up with every workout", color: Color.purple),
        (icon: "trophy.fill", title: "Achievements", description: "Unlock badges & rewards", color: Color.orange)
    ]
}

struct ModernFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

struct UserInfoPage: View {
    @Binding var username: String
    @Binding var trainerName: String
    @Binding var currentPage: Int
    @FocusState private var focusedField: Field?
    @State private var showForm = false
    
    enum Field {
        case username, trainerName
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Header section
            VStack(spacing: 20) {
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white)
                    .scaleEffect(showForm ? 1 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showForm)
                
                VStack(spacing: 12) {
                    Text("Create Your Trainer")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Choose your identity in the Pokemon world")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(showForm ? 1 : 0)
                .offset(y: showForm ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2), value: showForm)
            }
            
            Spacer()
            
            // Form section
            VStack(spacing: 24) {
                ModernInputField(
                    placeholder: "Username",
                    text: $username,
                    icon: "at",
                    isFocused: focusedField == .username
                )
                .focused($focusedField, equals: .username)
                .opacity(showForm ? 1 : 0)
                .offset(x: showForm ? 0 : -50)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: showForm)
                
                ModernInputField(
                    placeholder: "Trainer Name",
                    text: $trainerName,
                    icon: "star.fill",
                    isFocused: focusedField == .trainerName
                )
                .focused($focusedField, equals: .trainerName)
                .opacity(showForm ? 1 : 0)
                .offset(x: showForm ? 0 : -50)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showForm)
                
                // Continue button
                Button(action: {
                    if !username.isEmpty && !trainerName.isEmpty {
                        currentPage = 2
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(username.isEmpty || trainerName.isEmpty ? 
                                  LinearGradient(colors: [Color.white.opacity(0.2), Color.white.opacity(0.2)], startPoint: .leading, endPoint: .trailing) : 
                                  LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing))
                    )
                }
                .disabled(username.isEmpty || trainerName.isEmpty)
                .opacity(showForm ? 1 : 0)
                .offset(y: showForm ? 0 : 30)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.8), value: showForm)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                showForm = true
                focusedField = .username
            }
        }
    }
}

struct ModernInputField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    let isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !text.isEmpty || isFocused {
                Text(placeholder)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isFocused ? .white : .white.opacity(0.6))
                    .frame(width: 20)
                
                TextField(text.isEmpty && !isFocused ? placeholder : "", text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(isFocused ? 0.15 : 0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(isFocused ? 0.4 : 0.2), lineWidth: 1)
                    )
            )
        }
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .animation(.easeInOut(duration: 0.2), value: text.isEmpty)
    }
}

struct ReadyPage: View {
    let username: String
    let trainerName: String
    @ObservedObject var viewModel: AppViewModel
    @State private var isAnimating = false
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success animation
            VStack(spacing: 32) {
                ZStack {
                    // Pulsing rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 2)
                            .frame(width: CGFloat(120 + index * 40), height: CGFloat(120 + index * 40))
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .opacity(isAnimating ? 0 : 1)
                            .animation(.easeOut(duration: 2).repeatForever().delay(Double(index) * 0.3), value: isAnimating)
                    }
                    
                    // Center checkmark
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(showContent ? 1 : 0.3)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showContent)
                }
                
                VStack(spacing: 16) {
                    Text("Welcome, \(trainerName)!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: showContent)
                    
                    Text("Your Pokemon journey begins now.\nReady to catch your first partner?")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.5), value: showContent)
                }
            }
            
            Spacer()
            
            // Start button
            Button(action: {
                viewModel.createUser(username: username, trainerName: trainerName)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Choose Your Starter Pokemon")
                        .font(.system(size: 18, weight: .bold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(colors: [Color.purple, Color.blue, Color.green], startPoint: .leading, endPoint: .trailing))
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                )
            }
            .disabled(username.isEmpty || trainerName.isEmpty)
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
            .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.7), value: showContent)
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isAnimating = true
                showContent = true
            }
        }
    }
}

#Preview {
    ModernOnboardingView(viewModel: AppViewModel())
}