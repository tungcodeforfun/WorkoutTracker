//
//  WorkoutView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var currentWorkout = Workout()
    @State private var showingExerciseSheet = false
    @State private var selectedExerciseType: ExerciseType = .strength
    @State private var workoutStartTime = Date()
    @State private var isWorkoutActive = false
    
    var body: some View {
        NavigationView {
            VStack {
                if isWorkoutActive {
                    ActiveWorkoutView(
                        workout: $currentWorkout,
                        startTime: workoutStartTime,
                        onAddExercise: { showingExerciseSheet = true },
                        onFinish: finishWorkout
                    )
                } else {
                    StartWorkoutView(onStart: startWorkout)
                }
            }
            .navigationTitle("Workout")
            .sheet(isPresented: $showingExerciseSheet) {
                AddExerciseView(workout: $currentWorkout)
            }
        }
    }
    
    private func startWorkout() {
        currentWorkout = Workout()
        workoutStartTime = Date()
        isWorkoutActive = true
    }
    
    private func finishWorkout() {
        currentWorkout.totalDuration = Date().timeIntervalSince(workoutStartTime)
        viewModel.completeWorkout(currentWorkout)
        isWorkoutActive = false
        viewModel.selectedTab = 0
    }
}

struct StartWorkoutView: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            Text("Ready to Train?")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your Pokemon will gain XP from your workout!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onStart) {
                Text("Start Workout")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.blue)
                    )
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ActiveWorkoutView: View {
    @Binding var workout: Workout
    let startTime: Date
    let onAddExercise: () -> Void
    let onFinish: () -> Void
    @State private var elapsedTime = ""
    
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Workout in Progress")
                    .font(.headline)
                
                Text(elapsedTime)
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.medium)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.2))
            )
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(workout.exercises) { exercise in
                        ExerciseRow(exercise: exercise)
                    }
                    
                    Button(action: onAddExercise) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Exercise")
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(.blue)
                        )
                    }
                }
            }
            
            HStack(spacing: 16) {
                Text("Total XP: \(workout.totalExperience)")
                    .font(.headline)
                    .foregroundColor(.green)
                
                Spacer()
                
                Button(action: onFinish) {
                    Text("Finish Workout")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(workout.exercises.isEmpty ? Color.gray : Color.green)
                        )
                }
                .disabled(workout.exercises.isEmpty)
            }
        }
        .padding()
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            let minutes = Int(elapsed) / 60
            let seconds = Int(elapsed) % 60
            elapsedTime = String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                
                Spacer()
                
                Text("+\(exercise.experiencePoints) XP")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.2))
                    )
            }
            
            HStack(spacing: 16) {
                if let sets = exercise.sets, let reps = exercise.reps {
                    Label("\(sets) x \(reps)", systemImage: "number")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let weight = exercise.weight {
                    Label("\(Int(weight)) kg", systemImage: "scalemass")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let duration = exercise.duration {
                    Label("\(Int(duration/60)) min", systemImage: "timer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let distance = exercise.distance {
                    Label("\(distance, specifier: "%.1f") km", systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    WorkoutView(viewModel: AppViewModel())
}