//
//  ModernAddExerciseView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernAddExerciseView: View {
    @Binding var workout: Workout
    @Environment(\.dismiss) var dismiss
    
    @State private var exerciseName = ""
    @State private var exerciseType: ExerciseType = .strength
    @State private var sets = ""
    @State private var reps = ""
    @State private var weight = ""
    @State private var duration = ""
    @State private var distance = ""
    @State private var notes = ""
    @State private var selectedCommonExercise: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.Colors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xLarge) {
                        // Header
                        VStack(spacing: Theme.Spacing.small) {
                            Text("Add Exercise")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(Theme.Colors.primaryText)
                            
                            Text("Track your workout and earn XP!")
                                .font(.subheadline)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                        .padding(.top)
                        
                        // Exercise Selection Card
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            Text("Exercise")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.primaryText)
                            
                            // Common exercises picker
                            Menu {
                                Button("Custom Exercise") {
                                    selectedCommonExercise = nil
                                    exerciseName = ""
                                }
                                
                                ForEach(Array(commonExercises.keys).sorted(), id: \.self) { exercise in
                                    Button(exercise) {
                                        selectedCommonExercise = exercise
                                        exerciseName = exercise
                                        if let type = commonExercises[exercise] {
                                            exerciseType = type
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedCommonExercise ?? "Choose Exercise")
                                        .foregroundColor(selectedCommonExercise == nil ? Theme.Colors.secondaryText : Theme.Colors.primaryText)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(Theme.Colors.secondaryText)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .fill(Theme.Colors.surface)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                                .stroke(Theme.Colors.accent.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                            
                            // Custom exercise name field
                            if selectedCommonExercise == nil {
                                TextField("Enter exercise name", text: $exerciseName)
                                    .font(.body)
                                    .foregroundColor(Theme.Colors.primaryText)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .fill(Theme.Colors.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                            
                            // Exercise type picker
                            VStack(alignment: .leading, spacing: Theme.Spacing.small) {
                                Text("Type")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.primaryText)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: Theme.Spacing.small) {
                                        ForEach(ExerciseType.allCases, id: \.self) { type in
                                            ExerciseTypeChip(
                                                type: type,
                                                isSelected: exerciseType == type
                                            ) {
                                                exerciseType = type
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 1)
                                }
                            }
                        }
                        .modernCard()
                        
                        // Exercise Details Card
                        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
                            Text("Details")
                                .font(.headline)
                                .foregroundColor(Theme.Colors.primaryText)
                            
                            if exerciseType == .strength {
                                HStack(spacing: Theme.Spacing.medium) {
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                        Text("Sets")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Theme.Colors.primaryText)
                                        TextField("0", text: $sets)
                                            .font(.body)
                                            .foregroundColor(Theme.Colors.primaryText)
                                            #if os(iOS)
                                            .keyboardType(.numberPad)
                                            #endif
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .fill(Theme.Colors.surface)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                            .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                                    )
                                            )
                                    }
                                    
                                    Text("×")
                                        .font(.title2)
                                        .foregroundColor(Theme.Colors.secondaryText)
                                        .padding(.top, 30)
                                    
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                        Text("Reps")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(Theme.Colors.primaryText)
                                        TextField("0", text: $reps)
                                            .font(.body)
                                            .foregroundColor(Theme.Colors.primaryText)
                                            #if os(iOS)
                                            .keyboardType(.numberPad)
                                            #endif
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .fill(Theme.Colors.surface)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                            .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                                    )
                                            )
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                    Text("Weight (kg)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.Colors.primaryText)
                                    TextField("0", text: $weight)
                                        .font(.body)
                                        .foregroundColor(Theme.Colors.primaryText)
                                        #if os(iOS)
                                        .keyboardType(.decimalPad)
                                        #endif
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .fill(Theme.Colors.surface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                        .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                            
                            if exerciseType == .cardio {
                                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                    Text("Duration (minutes)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.Colors.primaryText)
                                    TextField("0", text: $duration)
                                        .font(.body)
                                        .foregroundColor(Theme.Colors.primaryText)
                                        #if os(iOS)
                                        .keyboardType(.numberPad)
                                        #endif
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .fill(Theme.Colors.surface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                        .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                    Text("Distance (km)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(Theme.Colors.primaryText)
                                    TextField("0.0", text: $distance)
                                        .font(.body)
                                        .foregroundColor(Theme.Colors.primaryText)
                                        #if os(iOS)
                                        .keyboardType(.decimalPad)
                                        #endif
                                        .padding()
                                        .background(
                                            RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                .fill(Theme.Colors.surface)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                        .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
                                Text("Notes (optional)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Theme.Colors.primaryText)
                                TextField("Add any notes...", text: $notes)
                                    .font(.body)
                                    .foregroundColor(Theme.Colors.primaryText)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                            .fill(Theme.Colors.surface)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                                                    .stroke(Theme.Colors.accent.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        .modernCard()
                        
                        // XP Preview Card
                        VStack(spacing: Theme.Spacing.medium) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(Theme.Colors.warning)
                                
                                Text("XP Preview")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.primaryText)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("Your Pokemon will gain")
                                    .foregroundColor(Theme.Colors.secondaryText)
                                
                                Spacer()
                                
                                Text("\(calculateXP()) XP")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.Colors.success)
                            }
                        }
                        .modernCard()
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .overlay(
                // Bottom action bar
                VStack {
                    Spacer()
                    
                    HStack(spacing: Theme.Spacing.medium) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .secondaryButtonStyle()
                        .frame(width: 100)
                        
                        Button(action: addExercise) {
                            HStack {
                                Text("Add Exercise")
                                Image(systemName: "plus.circle.fill")
                            }
                        }
                        .primaryButtonStyle()
                        .disabled(exerciseName.isEmpty)
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Theme.Colors.surface)
                            .shadow(color: Theme.Colors.shadow, radius: 10, x: 0, y: -2)
                            .ignoresSafeArea(edges: .bottom)
                    )
                }
            )
        }
    }
    
    private func calculateXP() -> Int {
        var exercise = Exercise(name: exerciseName.isEmpty ? "Exercise" : exerciseName, type: exerciseType)
        exercise.sets = Int(sets)
        exercise.reps = Int(reps)
        exercise.weight = Double(weight)
        exercise.duration = Double(duration).map { $0 * 60 }
        exercise.distance = Double(distance)
        return exercise.experiencePoints
    }
    
    private func addExercise() {
        var exercise = Exercise(name: exerciseName, type: exerciseType)
        exercise.sets = Int(sets)
        exercise.reps = Int(reps)
        exercise.weight = Double(weight)
        exercise.duration = Double(duration).map { $0 * 60 }
        exercise.distance = Double(distance)
        exercise.notes = notes.isEmpty ? nil : notes
        
        withAnimation(.spring()) {
            workout.exercises.append(exercise)
        }
        dismiss()
    }
}


struct ExerciseTypeChip: View {
    let type: ExerciseType
    let isSelected: Bool
    let action: () -> Void
    
    private var chipColor: Color {
        switch type {
        case .strength: return .red
        case .cardio: return .blue
        case .flexibility: return .green
        case .sports: return .orange
        case .other: return .purple
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(type.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : chipColor)
                .padding(.horizontal, Theme.Spacing.medium)
                .padding(.vertical, Theme.Spacing.small)
                .background(
                    Capsule()
                        .fill(isSelected ? chipColor : chipColor.opacity(0.1))
                )
        }
    }
}

#Preview {
    ModernAddExerciseView(workout: .constant(Workout()))
}