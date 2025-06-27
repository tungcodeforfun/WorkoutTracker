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
    
    private var isValid: Bool {
        !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            // Dark gradient background like other modern views
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.25), Color(red: 0.25, green: 0.35, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerSection
                
                ScrollView {
                    VStack(spacing: Theme.Spacing.xLarge) {
                        subtitleSection
                        exerciseSelectionSection
                        exerciseDetailsSection
                        xpPreviewSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
        }
    }
}

// MARK: - View Components
extension ModernAddExerciseView {
    private var headerSection: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text("Add Exercise")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
            
            Button("Add") {
                addExercise()
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(isValid ? .blue : .white.opacity(0.5))
            .disabled(!isValid)
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var subtitleSection: some View {
        VStack(spacing: Theme.Spacing.small) {
            Text("Track your workout and earn XP!")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .padding(.top)
        }
    }
    
    private var exerciseSelectionSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Exercise")
                .font(.headline)
                .foregroundColor(.white)
            
            exercisePickerMenu
            
            if selectedCommonExercise == nil {
                customExerciseField
            }
            
            exerciseTypeSelector
        }
        .padding(Theme.Spacing.medium)
    }
    
    private var exercisePickerMenu: some View {
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
                    .foregroundColor(selectedCommonExercise == nil ? .white.opacity(0.6) : .white)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var customExerciseField: some View {
        TextField("Enter exercise name", text: $exerciseName)
            .font(.body)
            .foregroundColor(.white)
            .textFieldStyle(PlainTextFieldStyle())
            .accentColor(.blue)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
    
    private var exerciseTypeSelector: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            Text("Type")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
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
    
    private var exerciseDetailsSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.medium) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.white)
            
            if exerciseType == .strength {
                strengthFields
            }
            
            if exerciseType == .cardio {
                cardioFields
            }
            
            notesField
        }
        .padding(Theme.Spacing.medium)
    }
    
    private var strengthFields: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack(spacing: Theme.Spacing.medium) {
                inputField(title: "Sets", text: $sets, placeholder: "0")
                
                Text("×")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 30)
                
                inputField(title: "Reps", text: $reps, placeholder: "0")
            }
            
            inputField(title: "Weight (kg)", text: $weight, placeholder: "0")
        }
    }
    
    private var cardioFields: some View {
        VStack(spacing: Theme.Spacing.medium) {
            inputField(title: "Duration (minutes)", text: $duration, placeholder: "0")
            inputField(title: "Distance (km)", text: $distance, placeholder: "0.0")
        }
    }
    
    private var notesField: some View {
        inputField(title: "Notes (optional)", text: $notes, placeholder: "Add any notes...")
    }
    
    private func inputField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xSmall) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            TextField(placeholder, text: text)
                .font(.body)
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
                .accentColor(.blue)
                #if os(iOS)
                .keyboardType(title.contains("Weight") || title.contains("Distance") ? .decimalPad : (title.contains("Notes") ? .default : .numberPad))
                #endif
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var xpPreviewSection: some View {
        VStack(spacing: Theme.Spacing.medium) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.yellow)
                
                Text("XP Preview")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack {
                Text("Your companion will gain")
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(calculateXP()) XP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
        }
        .padding(Theme.Spacing.medium)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
            .fill(Color.clear)
    }
}

// MARK: - Functions
extension ModernAddExerciseView {
    private func calculateXP() -> Int {
        var exercise = Exercise(name: exerciseName.isEmpty ? "Exercise" : exerciseName, type: exerciseType)
        exercise.sets = sets.isEmpty ? nil : Int(sets)
        exercise.reps = reps.isEmpty ? nil : Int(reps)
        exercise.weight = weight.isEmpty ? nil : Double(weight)
        exercise.duration = duration.isEmpty ? nil : (Double(duration) != nil ? Double(duration)! * 60 : nil)
        exercise.distance = distance.isEmpty ? nil : Double(distance)
        return exercise.experiencePoints
    }
    
    private func addExercise() {
        let trimmedName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        var exercise = Exercise(name: trimmedName, type: exerciseType)
        
        // Convert string inputs to numbers, defaulting to nil if invalid
        exercise.sets = sets.isEmpty ? nil : Int(sets)
        exercise.reps = reps.isEmpty ? nil : Int(reps)
        exercise.weight = weight.isEmpty ? nil : Double(weight)
        exercise.duration = duration.isEmpty ? nil : (Double(duration) != nil ? Double(duration)! * 60 : nil)
        exercise.distance = distance.isEmpty ? nil : Double(distance)
        exercise.notes = notes.isEmpty ? nil : notes
        
        print("Adding exercise: \(exercise.name), XP: \(exercise.experiencePoints)")
        
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
                        .fill(isSelected ? chipColor : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(chipColor.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ModernAddExerciseView(workout: .constant(Workout()))
}