//
//  ModernWorkoutView.swift
//  WorkoutTracker
//
//  Created by Tung Nguyen on 6/27/25.
//

import SwiftUI

struct ModernWorkoutView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var currentWorkout = Workout()
    @State private var showingExerciseSheet = false
    @State private var workoutStartTime = Date()
    @State private var isWorkoutActive = false
    @State private var showingCompletionAnimation = false
    @State private var isPaused = false
    
    var body: some View {
        ZStack {
            // Dark gradient background like other modern views
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.25), Color(red: 0.25, green: 0.35, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isWorkoutActive {
                ModernActiveWorkoutView(
                    workout: $currentWorkout,
                    startTime: workoutStartTime,
                    activeCompanion: viewModel.currentUser?.activeCompanion,
                    isPaused: $isPaused,
                    onAddExercise: { showingExerciseSheet = true },
                    onFinish: finishWorkout
                )
            } else {
                ModernStartWorkoutView(
                    activeCompanion: viewModel.currentUser?.activeCompanion,
                    onStart: startWorkout
                )
            }
        }
        .sheet(isPresented: $showingExerciseSheet) {
            ModernAddExerciseView(workout: $currentWorkout)
        }
        .overlay(
            WorkoutCompletionOverlay(isShowing: $showingCompletionAnimation, workout: currentWorkout)
        )
    }
    
    private func startWorkout() {
        currentWorkout = Workout()
        workoutStartTime = Date()
        withAnimation(.spring()) {
            isWorkoutActive = true
        }
    }
    
    private func finishWorkout() {
        currentWorkout.totalDuration = Date().timeIntervalSince(workoutStartTime)
        
        // Show completion animation
        showingCompletionAnimation = true
        
        // Complete workout after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            viewModel.completeWorkout(currentWorkout)
            showingCompletionAnimation = false
            withAnimation(.spring()) {
                isWorkoutActive = false
            }
            viewModel.selectedTab = 0
        }
    }
}

struct ModernStartWorkoutView: View {
    let activeCompanion: Companion?
    let onStart: () -> Void
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.25), Color(red: 0.25, green: 0.35, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: Theme.Spacing.xLarge) {
                Spacer()
            
            // Companion motivation section
            if let companion = activeCompanion {
                VStack(spacing: Theme.Spacing.large) {
                    // Companion avatar
                    ZStack {
                        Circle()
                            .stroke(companion.type.color.opacity(0.3), lineWidth: 2)
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        
                        Text(String(companion.name.prefix(1)))
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(companion.type.color)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            pulseAnimation = true
                        }
                    }
                    
                    VStack(spacing: Theme.Spacing.small) {
                        Text("\(companion.nickname ?? companion.name) is ready to train!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("Level \(companion.level) • \(companion.experience)/\(companion.experienceForNextLevel()) XP")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            
            // Motivational content
            VStack(spacing: Theme.Spacing.medium) {
                Text("Ready to Power Up?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Every rep makes your Companion stronger!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Workout benefits
            VStack(spacing: Theme.Spacing.medium) {
                WorkoutBenefit(icon: "bolt.fill", text: "Gain XP for your Companion", color: Theme.Colors.warning)
                WorkoutBenefit(icon: "trophy.fill", text: "Unlock new achievements", color: Theme.Colors.accent)
                WorkoutBenefit(icon: "heart.fill", text: "Get stronger together", color: .red)
            }
            .padding(.horizontal)
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: Theme.Spacing.small) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Start Training")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            
                Spacer()
            }
            .padding()
        }
    }
}

struct WorkoutBenefit: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.small)
    }
}

struct ModernActiveWorkoutView: View {
    @Binding var workout: Workout
    let startTime: Date
    let activeCompanion: Companion?
    @Binding var isPaused: Bool
    let onAddExercise: () -> Void
    let onFinish: () -> Void
    
    @State private var elapsedTime = ""
    @State private var timer: Timer?
    @State private var showingXPGain = false
    @State private var pausedDuration: TimeInterval = 0
    @State private var pauseStartTime: Date?
    
    var body: some View {
        ZStack {
            // Dark gradient background
            LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.25), Color(red: 0.25, green: 0.35, blue: 0.55)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
            // Header with Companion and timer
            VStack(spacing: Theme.Spacing.medium) {
                if let companion = activeCompanion {
                    ModernCompanionWorkoutHeader(companion: companion, elapsedTime: elapsedTime, isPaused: isPaused)
                }
                
                // XP Earned
                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.yellow)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("XP Earned")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(workout.totalExperience) XP")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .padding()
            
            // Exercises list
            ScrollView {
                LazyVStack(spacing: Theme.Spacing.medium) {
                    ForEach(workout.exercises) { exercise in
                        ModernExerciseCard(exercise: exercise)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    // Add exercise button
                    Button(action: onAddExercise) {
                        HStack(spacing: Theme.Spacing.medium) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(Theme.Colors.accent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Add Exercise")
                                    .font(.headline)
                                    .foregroundColor(Theme.Colors.primaryText)
                                
                                Text("Keep building XP!")
                                    .font(.caption)
                                    .foregroundColor(Theme.Colors.secondaryText)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(Theme.Colors.secondaryText)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                .fill(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
            }
            
            // Bottom action bar
            VStack(spacing: Theme.Spacing.medium) {
                Divider()
                
                HStack(spacing: Theme.Spacing.medium) {
                    Button(isPaused ? "Resume" : "Pause") {
                        withAnimation(.spring()) {
                            isPaused.toggle()
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 100, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onFinish) {
                        HStack(spacing: 8) {
                            Text("Finish Workout")
                                .font(.system(size: 16, weight: .semibold))
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(workout.exercises.isEmpty)
                    .opacity(workout.exercises.isEmpty ? 0.6 : 1.0)
                }
                .padding(.horizontal)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
            }
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: isPaused) { _, paused in
            if paused {
                pauseStartTime = Date()
            } else {
                if let pauseStart = pauseStartTime {
                    pausedDuration += Date().timeIntervalSince(pauseStart)
                    pauseStartTime = nil
                }
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if !isPaused {
                let totalElapsed = Date().timeIntervalSince(startTime)
                let currentPausedDuration = pausedDuration + (pauseStartTime != nil ? Date().timeIntervalSince(pauseStartTime!) : 0)
                let activeElapsed = totalElapsed - currentPausedDuration
                let minutes = Int(activeElapsed) / 60
                let seconds = Int(activeElapsed) % 60
                elapsedTime = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct ModernCompanionWorkoutHeader: View {
    let companion: Companion
    let elapsedTime: String
    let isPaused: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Companion avatar (smaller for header)
            ZStack {
                Circle()
                    .stroke(companion.type.color.opacity(0.3), lineWidth: 2)
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                
                Text(String(companion.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(companion.type.color)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(companion.nickname ?? companion.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(isPaused ? "Taking a Break" : "Training Hard!")
                    .font(.caption)
                    .foregroundColor(isPaused ? .orange : companion.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .stroke((isPaused ? Color.orange : companion.type.color).opacity(0.3), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            // Timer
            VStack(alignment: .trailing) {
                Text(elapsedTime)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .monospacedDigit()
                
                Text("Workout Time")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ModernExerciseCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.small) {
            HStack {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                    Text("\(exercise.experiencePoints)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(Theme.Colors.success)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .stroke(Theme.Colors.success.opacity(0.3), lineWidth: 1)
                )
            }
            
            // Exercise details with modern icons
            FlowLayout(spacing: Theme.Spacing.small) {
                if let sets = exercise.sets, let reps = exercise.reps {
                    ExerciseDetailChip(icon: "number", text: "\(sets) × \(reps)", color: Theme.Colors.accent)
                }
                
                if let weight = exercise.weight {
                    ExerciseDetailChip(icon: "scalemass", text: "\(Int(weight)) kg", color: .orange)
                }
                
                if let duration = exercise.duration {
                    ExerciseDetailChip(icon: "timer", text: "\(Int(duration/60)) min", color: .blue)
                }
                
                if let distance = exercise.distance {
                    ExerciseDetailChip(icon: "location", text: String(format: "%.1f km", distance), color: .green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ExerciseDetailChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FlowLayout: Layout {
    let spacing: CGFloat
    
    init(spacing: CGFloat = 8) {
        self.spacing = spacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return arrangeViews(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let arrangement = arrangeViews(sizes: sizes, proposal: proposal)
        
        for (index, subview) in subviews.enumerated() {
            let position = arrangement.positions[index]
            subview.place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func arrangeViews(sizes: [CGSize], proposal: ProposedViewSize) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? 300
        var positions: [CGPoint] = []
        var currentRowY: CGFloat = 0
        var currentRowX: CGFloat = 0
        var currentRowHeight: CGFloat = 0
        
        for size in sizes {
            if currentRowX + size.width > maxWidth && currentRowX > 0 {
                currentRowY += currentRowHeight + spacing
                currentRowX = 0
                currentRowHeight = 0
            }
            
            positions.append(CGPoint(x: currentRowX, y: currentRowY))
            currentRowX += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
        
        return (
            size: CGSize(width: maxWidth, height: currentRowY + currentRowHeight),
            positions: positions
        )
    }
}

struct WorkoutCompletionOverlay: View {
    @Binding var isShowing: Bool
    let workout: Workout
    @State private var animationPhase = 0
    
    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack(spacing: Theme.Spacing.large) {
                    // Success animation
                    ZStack {
                        Circle()
                            .stroke(Theme.Colors.success.opacity(0.4), lineWidth: 2)
                            .frame(width: 120, height: 120)
                            .scaleEffect(animationPhase >= 1 ? 1.2 : 0.8)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Theme.Colors.success)
                            .scaleEffect(animationPhase >= 2 ? 1.0 : 0.5)
                    }
                    
                    VStack(spacing: Theme.Spacing.small) {
                        Text("Workout Complete!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .opacity(animationPhase >= 3 ? 1 : 0)
                        
                        Text("Your Companion gained \(workout.totalExperience) XP!")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(animationPhase >= 4 ? 1 : 0)
                    }
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 0.3)) {
                        animationPhase = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.spring()) {
                            animationPhase = 2
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            animationPhase = 3
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                        withAnimation(.easeOut(duration: 0.3)) {
                            animationPhase = 4
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ModernWorkoutView(viewModel: AppViewModel())
}