//
//  CompanionListView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct CompanionListView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var selectedCompanion: Companion?
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
                    Text("My Companions")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    if let user = viewModel.currentUser {
                        Text("\(user.companions.count)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
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
                        if user.companions.isEmpty {
                            EmptyCompanionState()
                                .padding(.top, 60)
                                .opacity(showContent ? 1 : 0)
                                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.3), value: showContent)
                        } else {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(Array(user.companions.enumerated()), id: \.element.id) { index, companion in
                                    Button(action: {
                                        selectedCompanion = companion
                                    }) {
                                        CompanionDetailCard(
                                            companion: companion,
                                            isActive: companion.id == user.activeCompanionId
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
        .sheet(item: $selectedCompanion) { companion in
            CompanionManagementSheet(companion: companion, viewModel: viewModel)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showContent = true
            }
        }
    }
}

struct CompanionDetailCard: View {
    let companion: Companion
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
            
            // Companion avatar
            ZStack {
                Circle()
                    .stroke(companion.type.color.opacity(0.4), lineWidth: 2)
                    .frame(width: 80, height: 80)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(String(companion.name.prefix(1)))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(companion.type.color)
            }
            
            VStack(spacing: 8) {
                Text(companion.nickname ?? companion.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text("Level \(companion.level)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(companion.type.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .stroke(companion.type.color.opacity(0.3), lineWidth: 1)
                        )
                    
                    Text(companion.type.rawValue)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
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
                    
                    Text("\(companion.experience)/\(companion.experienceForNextLevel())")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                ProgressBar(
                    value: Double(companion.experience),
                    maxValue: Double(companion.experienceForNextLevel()),
                    color: companion.type.color
                )
                .frame(height: 4)
            }
        }
        .padding(16)
        .frame(height: 240)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isActive ? LinearGradient(colors: [Color.green, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing) : LinearGradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: isActive ? 2 : 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .onAppear { isAnimating = true }
    }
}

struct EmptyCompanionState: View {
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.clear)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text("No Companions Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Complete your first workout to\nmeet your starter companion!")
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

struct CompanionManagementSheet: View {
    let companion: Companion
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
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    Text("Companion Details")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Save") {
                        if !nickname.isEmpty {
                            viewModel.updateCompanionNickname(companion.id, nickname: nickname)
                        }
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: showContent)
                
                // Companion Display
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .stroke(companion.type.color.opacity(0.4), lineWidth: 2)
                            .frame(width: 120, height: 120)
                        
                        Text(String(companion.name.prefix(1)))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(companion.type.color)
                    }
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: showContent)
                    
                    VStack(spacing: 16) {
                        Text(companion.nickname ?? companion.name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 16) {
                            StatRow(label: "Level", value: "\(companion.level)", color: companion.type.color)
                            StatRow(label: "Type", value: companion.type.rawValue, color: companion.type.color)
                        }
                        
                        StatRow(label: "Experience", value: "\(companion.experience)/\(companion.experienceForNextLevel())", color: companion.type.color)
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
                    
                    TextField(companion.name, text: $nickname)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.6), value: showContent)
                
                // Action Buttons
                VStack(spacing: 16) {
                    if viewModel.currentUser?.activeCompanionId != companion.id {
                        Button(action: {
                            viewModel.setActiveCompanion(companion.id)
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
                                LinearGradient(colors: [Color.blue, Color.purple], startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(12)
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(PlainButtonStyle())
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
            nickname = companion.nickname ?? ""
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

#Preview {
    CompanionListView(viewModel: AppViewModel())
}