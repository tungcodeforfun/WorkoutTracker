//
//  WatchCompanionCardView.swift
//  WorkoutTracker Watch App
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct WatchCompanionCardView: View {
    let companion: Companion
    
    var body: some View {
        VStack(spacing: 4) {
            // Companion Type Icon/Color
            Circle()
                .fill(companion.type.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(companion.type.rawValue.prefix(1).uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            // Companion Name
            Text(companion.nickname ?? companion.name)
                .font(.caption)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            // Level and XP
            HStack(spacing: 8) {
                Text("Lv.\(companion.level)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                // Mini XP Bar
                ProgressView(value: Double(companion.experience), total: Double(companion.experienceForNextLevel()))
                    .progressViewStyle(LinearProgressViewStyle(tint: companion.type.color))
                    .frame(height: 4)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}