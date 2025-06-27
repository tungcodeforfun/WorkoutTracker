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
    
    var body: some View {
        ZStack {
            Theme.Colors.background.ignoresSafeArea()
            
            if isWorkoutActive {
                ModernActiveWorkoutView(
                    workout: $currentWorkout,
                    startTime: workoutStartTime,
                    activePokemon: viewModel.currentUser?.activePokemon,
                    onAddExercise: { showingExerciseSheet = true },
                    onFinish: finishWorkout
                )
            } else {
                ModernStartWorkoutView(
                    activePokemon: viewModel.currentUser?.activePokemon,
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
    let activePokemon: Pokemon?
    let onStart: () -> Void
    @State private var pulseAnimation = false
    
    var body: some View {
        VStack(spacing: Theme.Spacing.xLarge) {
            Spacer()
            
            // Pokemon motivation section
            if let pokemon = activePokemon {
                VStack(spacing: Theme.Spacing.large) {
                    // Pokemon avatar
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [pokemon.type.color.opacity(0.3), pokemon.type.color.opacity(0.1)],
                                    center: .center,
                                    startRadius: 20,
                                    endRadius: 80
                                )
                            )
                            .frame(width: 160, height: 160)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        
                        Text(String(pokemon.name.prefix(1)))
                            .font(.system(size: 80, weight: .bold, design: .rounded))
                            .foregroundColor(pokemon.type.color)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            pulseAnimation = true
                        }
                    }
                    
                    VStack(spacing: Theme.Spacing.small) {
                        Text("\(pokemon.nickname ?? pokemon.name) is ready to train!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.primaryText)
                            .multilineTextAlignment(.center)
                        
                        Text("Level \(pokemon.level) • \(pokemon.experience)/\(pokemon.experienceForNextLevel()) XP")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                    }
                }
            }
            
            // Motivational content
            VStack(spacing: Theme.Spacing.medium) {
                Text("Ready to Power Up?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Every rep makes your Pokemon stronger!")
                    .font(.body)
                    .foregroundColor(Theme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            // Workout benefits
            VStack(spacing: Theme.Spacing.medium) {
                WorkoutBenefit(icon: "bolt.fill", text: "Gain XP for your Pokemon", color: Theme.Colors.warning)
                WorkoutBenefit(icon: "trophy.fill", text: "Unlock new achievements", color: Theme.Colors.accent)
                WorkoutBenefit(icon: "heart.fill", text: "Get stronger together", color: .red)
            }
            .padding(.horizontal)
            
            // Start button
            Button(action: onStart) {
                HStack(spacing: Theme.Spacing.small) {
                    Image(systemName: "play.fill")
                    Text("Start Training")
                }
                .font(.headline)
                .fontWeight(.semibold)
            }
            .primaryButtonStyle()
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
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
                        .fill(color.opacity(0.1))
                )
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Theme.Colors.primaryText)
            
            Spacer()
        }
        .padding(.vertical, Theme.Spacing.small)
    }
}

struct ModernActiveWorkoutView: View {
    @Binding var workout: Workout
    let startTime: Date
    let activePokemon: Pokemon?
    let onAddExercise: () -> Void
    let onFinish: () -> Void
    
    @State private var elapsedTime = ""
    @State private var timer: Timer?
    @State private var showingXPGain = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Pokemon and timer
            VStack(spacing: Theme.Spacing.medium) {
                if let pokemon = activePokemon {
                    ModernPokemonWorkoutHeader(pokemon: pokemon, elapsedTime: elapsedTime)
                }
                
                // XP Progress
                VStack(spacing: Theme.Spacing.small) {
                    HStack {
                        Text("Workout XP")
                            .font(.subheadline)
                            .foregroundColor(Theme.Colors.secondaryText)
                        
                        Spacer()
                        
                        Text("\(workout.totalExperience) XP")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Theme.Colors.success)
                    }
                    
                    ProgressView(value: Double(workout.totalExperience), total: 100.0)
                        .tint(Theme.Colors.success)
                        .scaleEffect(y: 2)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(Theme.Colors.surface)
                        .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
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
                                .fill(Theme.Colors.accent.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                                        .stroke(Theme.Colors.accent, lineWidth: 1)
                                        .opacity(0.3)
                                )
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Bottom action bar
            VStack(spacing: Theme.Spacing.medium) {
                Divider()
                
                HStack(spacing: Theme.Spacing.medium) {
                    Button("Pause") {
                        // Pause functionality
                    }
                    .secondaryButtonStyle()
                    .frame(width: 100)
                    
                    Button(action: onFinish) {
                        HStack {
                            Text("Finish Workout")
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                    .primaryButtonStyle()
                    .disabled(workout.exercises.isEmpty)
                }
                .padding(.horizontal)
            }
            .background(Theme.Colors.surface)
        }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
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

struct ModernPokemonWorkoutHeader: View {
    let pokemon: Pokemon
    let elapsedTime: String
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: Theme.Spacing.medium) {
            // Pokemon avatar (smaller for header)
            ZStack {
                Circle()
                    .fill(pokemon.type.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                
                Text(String(pokemon.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(pokemon.type.color)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(pokemon.nickname ?? pokemon.name)
                    .font(.headline)
                    .foregroundColor(Theme.Colors.primaryText)
                
                Text("Training Hard!")
                    .font(.caption)
                    .foregroundColor(pokemon.type.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(pokemon.type.color.opacity(0.1))
                    )
            }
            
            Spacer()
            
            // Timer
            VStack(alignment: .trailing) {
                Text(elapsedTime)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.Colors.primaryText)
                    .monospacedDigit()
                
                Text("Workout Time")
                    .font(.caption2)
                    .foregroundColor(Theme.Colors.secondaryText)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.surface)
                .shadow(color: Theme.Colors.shadow, radius: 6, x: 0, y: 3)
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
                    .foregroundColor(Theme.Colors.primaryText)
                
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
                        .fill(Theme.Colors.success.opacity(0.1))
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
                .fill(Theme.Colors.surface)
                .shadow(color: Theme.Colors.shadow, radius: 4, x: 0, y: 2)
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
                .fill(color.opacity(0.1))
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
                            .fill(Theme.Colors.success.opacity(0.2))
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
                        
                        Text("Your Pokemon gained \(workout.totalExperience) XP!")
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