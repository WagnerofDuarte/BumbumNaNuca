//
//  ExerciseHistoryListView.swift
//  BumbumNaNuca
//
//  Created by speckit.implement on 2026
//  Feature: 003-mvp-completion - US4 Exercise History
//

import SwiftUI
import SwiftData

/// List of all exercises grouped by muscle group with stats
struct ExerciseHistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()
    @Query private var allExercises: [Exercise]
    @Query private var allSets: [ExerciseSet]
    
    // Group exercises by muscle group
    private var groupedExercises: [(MuscleGroup, [Exercise])] {
        // Filter exercises that have at least one set
        let exerciseIdsWithSets = Set(allSets.compactMap { $0.exercise?.id })
        let exercisesWithSets = allExercises.filter { exerciseIdsWithSets.contains($0.id) }
        let grouped = Dictionary(grouping: exercisesWithSets) { $0.muscleGroup }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    }
    
    var body: some View {
        Group {
            if groupedExercises.isEmpty {
                // Empty state
                EmptyStateView(
                    icon: "dumbbell",
                    title: "Nenhum exercício realizado",
                    message: "Complete seu primeiro treino para ver o histórico de exercícios"
                )
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        ForEach(groupedExercises, id: \.0) { muscleGroup, exercises in
                            VStack(alignment: .leading, spacing: 12) {
                                // Muscle group header
                                Text(muscleGroup.rawValue)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                // Exercises in this group
                                ForEach(exercises) { exercise in
                                    NavigationLink(value: exercise) {
                                        ExerciseStatsRow(
                                            exercise: exercise,
                                            viewModel: viewModel
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                    .padding(.vertical)
                }
                .navigationDestination(for: Exercise.self) { exercise in
                    let exerciseSets = allSets.filter { $0.exercise?.id == exercise.id }
                    ExerciseHistoryView(
                        exerciseName: exercise.name,
                        allSets: exerciseSets,
                        viewModel: viewModel
                    )
                }
            }
        }
        .onAppear {
            viewModel.loadExerciseHistory(context: modelContext)
        }
    }
}

/// Row showing exercise stats summary
private struct ExerciseStatsRow: View {
    let exercise: Exercise
    let viewModel: ProgressViewModel
    @Query private var allSets: [ExerciseSet]
    
    private var exerciseSets: [ExerciseSet] {
        allSets.filter { $0.exercise?.id == exercise.id }
    }
    
    private var lastExecution: Date? {
        exerciseSets
            .map { $0.completedDate }
            .max()
    }
    
    private var totalSets: Int {
        exerciseSets.count
    }
    
    private var personalRecord: PersonalRecord? {
        guard !exerciseSets.isEmpty else { return nil }
        // Calculate PR locally since method is private
        let sortedSets = exerciseSets.sorted { ($0.weight ?? 0) > ($1.weight ?? 0) }
        guard let maxWeightSet = sortedSets.first,
              let maxWeight = maxWeightSet.weight else { return nil }
        let maxWeightSets = exerciseSets.filter { $0.weight == maxWeight }
        guard let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps }) else { return nil }
        return PersonalRecord(weight: maxWeight, reps: bestSet.reps, date: bestSet.completedDate)
    }
    
    private var relativeTime: String {
        guard let date = lastExecution else { return "Nunca" }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            return "Hoje"
        } else if calendar.isDateInYesterday(date) {
            return "Ontem"
        } else if let daysAgo = calendar.dateComponents([.day], from: date, to: now).day,
                  daysAgo < 7 {
            return "\(daysAgo)d atrás"
        } else if let weeksAgo = calendar.dateComponents([.weekOfYear], from: date, to: now).weekOfYear,
                  weeksAgo < 4 {
            return "\(weeksAgo)sem atrás"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: date)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        Text("Última vez: \(relativeTime)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Text("\(totalSets) séries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Personal Record badge
                if let pr = personalRecord {
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            
                            Text("PR")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("\(pr.reps)× \(String(format: "%.0f", pr.weight))kg")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
