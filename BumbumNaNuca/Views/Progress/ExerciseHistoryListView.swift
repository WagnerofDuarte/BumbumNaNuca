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
    
    // Group exercises by muscle group
    private var groupedExercises: [(MuscleGroup, [Exercise])] {
        let exercisesWithSets = allExercises.filter { !$0.sets.isEmpty }
        let grouped = Dictionary(grouping: exercisesWithSets) { $0.muscleGroup }
        return grouped.sorted { $0.key.rawValue < $1.key.rawValue }
            .map { ($0.key, $0.value.sorted { $0.name < $1.name }) }
    
    var body: some View {
        Group {
            if allExercises.filter({ !$0.sets.isEmpty }).isEmpty {
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
                    .padding(.vertical)
                }
                .navigationDestination(for: Exercise.self) { exercise in
                    ExerciseHistoryView(exercise: exercise, viewModel: viewModel)
                }
        .onAppear {
            viewModel.loadExerciseHistory(context: modelContext)
        }

/// Row showing exercise stats summary
struct ExerciseStatsRow: View {
    let exercise: Exercise
    let viewModel: ProgressViewModel
    
    private var lastExecution: Date? {
        exercise.sets
            .compactMap { $0.workoutSession?.startDate }
            .max()
    }
    
    private var totalSets: Int {
        exercise.sets.count
    }
    
    private var personalRecord: ProgressViewModel.PersonalRecord? {
        viewModel.calculatePersonalRecord(for: exercise)
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
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
