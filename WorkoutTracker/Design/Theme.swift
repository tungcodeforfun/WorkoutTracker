//
//  Theme.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct Theme {
    static let gradient = LinearGradient(
        colors: [Colors.gradientStart, Colors.gradientMiddle, Colors.gradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [Colors.accent, Colors.accentLight],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let cardBackground = Color.white
    static let cardShadow = Color.black.opacity(0.08)
    
    struct Colors {
        // Modern background colors (like X/Instagram)
        static let background = Color(red: 0.98, green: 0.98, blue: 0.99)  // Very light gray
        static let surface = Color.white
        static let cardBackground = Color(red: 0.97, green: 0.97, blue: 0.98)
        
        // Text colors (high contrast like modern apps)
        static let primaryText = Color(red: 0.05, green: 0.05, blue: 0.09)  // Almost black
        static let secondaryText = Color(red: 0.45, green: 0.45, blue: 0.55)  // Medium gray
        static let tertiaryText = Color(red: 0.65, green: 0.65, blue: 0.72)  // Light gray
        
        // Modern accent colors
        static let accent = Color(red: 0.00, green: 0.48, blue: 1.00)  // iOS Blue
        static let accentLight = Color(red: 0.20, green: 0.60, blue: 1.00)  // Lighter blue
        
        // Status colors (Instagram/X style)
        static let success = Color(red: 0.20, green: 0.78, blue: 0.35)  // Modern green
        static let warning = Color(red: 1.00, green: 0.58, blue: 0.00)  // Modern orange
        static let error = Color(red: 1.00, green: 0.23, blue: 0.19)     // Modern red
        static let like = Color(red: 1.00, green: 0.27, blue: 0.43)      // Instagram like red
        
        // Gradient colors
        static let gradientStart = Color(red: 0.85, green: 0.40, blue: 0.95)  // Purple
        static let gradientMiddle = Color(red: 1.00, green: 0.45, blue: 0.65) // Pink
        static let gradientEnd = Color(red: 1.00, green: 0.65, blue: 0.30)    // Orange
        
        // Dark mode ready
        static let separator = Color(red: 0.92, green: 0.92, blue: 0.95)
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
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Theme.gradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Theme.Colors.shadow, radius: 12, x: 0, y: 6)
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
                    .fill(Theme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                            .stroke(Theme.Colors.separator, lineWidth: 0.5)
                    )
                    .shadow(color: Theme.Colors.shadow, radius: 12, x: 0, y: 4)
            )
    }
}

extension View {
    func modernCard() -> some View {
        modifier(ModernCardModifier())
    }
}