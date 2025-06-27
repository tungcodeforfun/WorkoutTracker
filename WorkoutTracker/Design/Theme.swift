//
//  Theme.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct Theme {
    static let gradient = LinearGradient(
        colors: [Colors.accent, Colors.accent.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.08)
    
    struct Colors {
        static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
        static let surface = Color.white
        static let primaryText = Color(red: 0.1, green: 0.1, blue: 0.2)
        static let secondaryText = Color(red: 0.4, green: 0.4, blue: 0.5)
        static let accent = Color(red: 0.3, green: 0.5, blue: 1.0)
        static let success = Color(red: 0.2, green: 0.8, blue: 0.4)
        static let warning = Color(red: 1.0, green: 0.6, blue: 0.2)
        static let error = Color(red: 0.9, green: 0.3, blue: 0.3)
        static let shadow = Color.black.opacity(0.06)
    }
    
    struct Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 32
        static let xxLarge: CGFloat = 48
    }
    
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 24
        static let circular: CGFloat = 1000
    }
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Theme.cardBackground)
            .cornerRadius(Theme.CornerRadius.large)
            .shadow(color: Theme.cardShadow, radius: 10, x: 0, y: 4)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Theme.gradient)
            .cornerRadius(Theme.CornerRadius.medium)
            .shadow(color: Theme.Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(Theme.Colors.accent)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Theme.Colors.accent, lineWidth: 2)
            )
    }
}

struct ModernCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Theme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func modernCard() -> some View {
        modifier(ModernCardModifier())
    }
}