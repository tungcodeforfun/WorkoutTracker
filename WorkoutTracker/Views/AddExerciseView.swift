//
//  AddExerciseView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct AddExerciseView: View {
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
            Form {
                Section("Exercise Details") {
                    if !commonExercises.isEmpty {
                        Picker("Common Exercises", selection: $selectedCommonExercise) {
                            Text("Custom Exercise").tag(String?.none)
                            ForEach(Array(commonExercises.keys).sorted(), id: \.self) { exercise in
                                Text(exercise).tag(String?.some(exercise))
                            }
                        }
                        .onChange(of: selectedCommonExercise) { _, newValue in
                            if let exercise = newValue,
                               let type = commonExercises[exercise] {
                                exerciseName = exercise
                                exerciseType = type
                            }
                        }
                    }
                    
                    if selectedCommonExercise == nil {
                        TextField("Exercise Name", text: $exerciseName)
                    }
                    
                    Picker("Type", selection: $exerciseType) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                
                Section("Details") {
                    if exerciseType == .strength {
                        HStack {
                            TextField("Sets", text: $sets)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            
                            Text("x")
                            
                            TextField("Reps", text: $reps)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                        }
                        
                        HStack {
                            TextField("Weight", text: $weight)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                            Text("kg")
                        }
                    }
                    
                    if exerciseType == .cardio {
                        HStack {
                            TextField("Duration", text: $duration)
                                #if os(iOS)
                                .keyboardType(.numberPad)
                                #endif
                            Text("minutes")
                        }
                        
                        HStack {
                            TextField("Distance", text: $distance)
                                #if os(iOS)
                                .keyboardType(.decimalPad)
                                #endif
                            Text("km")
                        }
                    }
                    
                    TextField("Notes (optional)", text: $notes)
                }
                
                Section {
                    VStack(spacing: 8) {
                        Text("Experience Preview")
                            .font(.headline)
                        
                        Text("\(calculateXP()) XP")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
            .navigationTitle("Add Exercise")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addExercise() }
                        .disabled(exerciseName.isEmpty)
                }
            }
        }
    }
    
    private func calculateXP() -> Int {
        var exercise = Exercise(name: exerciseName, type: exerciseType)
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
        
        workout.exercises.append(exercise)
        dismiss()
    }
}

#Preview {
    AddExerciseView(workout: .constant(Workout()))
}