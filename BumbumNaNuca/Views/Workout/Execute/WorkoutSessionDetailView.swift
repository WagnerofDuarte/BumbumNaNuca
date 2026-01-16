//
//  WorkoutSessionDetailView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 16/01/26.
//  Feature 005: Workout Session Detail Screen
//

import SwiftUI
import SwiftData

/// Exibe detalhes de uma sessão de treino completada
struct WorkoutSessionDetailView: View {
    let session: WorkoutSession
    @Environment(\.navigateToWorkout) private var navigateToWorkout
    
    var body: some View {
        List {
            summarySection
            statisticsSection
            workoutPlanSection
            exercisesSection
            notesSection
        }
        .navigationTitle("Detalhes do Treino")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var summarySection: some View {
        Section("Resumo") {
            HStack {
                Label("Início", systemImage: "clock")
                Spacer()
                Text(session.startDate, style: .time)
                    .foregroundColor(.secondary)
            }
            
            if let endDate = session.endDate {
                HStack {
                    Label("Fim", systemImage: "clock.fill")
                    Spacer()
                    Text(endDate, style: .time)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Label("Duração", systemImage: "timer")
                Spacer()
                Text(session.formattedDuration)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var statisticsSection: some View {
        Section("Estatísticas") {
            HStack {
                Label("Exercícios", systemImage: "figure.strengthtraining.traditional")
                Spacer()
                Text("\(session.completedExercisesCount)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Total de Séries", systemImage: "square.stack.3d.up.fill")
                Spacer()
                Text("\(session.totalSets)")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("Total de Repetições", systemImage: "number")
                Spacer()
                Text("\(session.totalReps)")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var workoutPlanSection: some View {
        if let plan = session.workoutPlan {
            Section("Plano de Treino") {
                Button {
                    navigateToWorkout(plan)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if !plan.description.isEmpty {
                            Text(plan.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    @ViewBuilder
    private var exercisesSection: some View {
        if !session.exerciseSets.isEmpty {
            Section("Exercícios Realizados") {
                ForEach(groupedExercises, id: \.exercise.id) { group in
                    exerciseGroupView(group)
                }
            }
        }
    }
    
    @ViewBuilder
    private var notesSection: some View {
        if !session.notes.isEmpty {
            Section("Notas") {
                Text(session.notes)
            }
        }
    }
    
    @ViewBuilder
    private func exerciseGroupView(_ group: (exercise: Exercise, sets: [ExerciseSet])) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.exercise.name)
                .font(.headline)
            
            ForEach(Array(group.sets.enumerated()), id: \.offset) { index, set in
                setRowView(index: index, set: set)
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func setRowView(index: Int, set: ExerciseSet) -> some View {
        HStack {
            Text("Série \(index + 1)")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            if let weight = set.weight, weight > 0 {
                Text("\(Int(weight))kg")
                    .font(.caption)
            }
            Text("×")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(set.reps)")
                .font(.caption)
        }
    }
    
    // MARK: - Computed Properties
    
    private var groupedExercises: [(exercise: Exercise, sets: [ExerciseSet])] {
        let grouped = Dictionary(grouping: session.exerciseSets) { $0.exercise }
        
        let mapped: [(exercise: Exercise, sets: [ExerciseSet])] = grouped.compactMap { (exercise: Exercise?, sets: [ExerciseSet]) -> (exercise: Exercise, sets: [ExerciseSet])? in
            guard let exercise = exercise else { return nil }
            let sortedSets = sets.sorted(by: { $0.completedDate < $1.completedDate })
            return (exercise: exercise, sets: sortedSets)
        }
        
        let sorted = mapped.sorted { first, second in
            let firstTimestamp = first.sets.first?.completedDate ?? Date()
            let secondTimestamp = second.sets.first?.completedDate ?? Date()
            return firstTimestamp < secondTimestamp
        }
        
        return sorted
    }
}

#Preview {
    NavigationStack {
        WorkoutSessionDetailView(
            session: WorkoutSession(
                startDate: Date().addingTimeInterval(-3600),
                endDate: Date(),
                isCompleted: true
            )
        )
    }
    .modelContainer(for: WorkoutSession.self, inMemory: true)
}
