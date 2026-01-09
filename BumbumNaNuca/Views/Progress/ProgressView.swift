//
//  ProgressView.swift
//  BumbumNaNuca
//
//  Created by speckit.implement on 2026
//  Feature: 003-mvp-completion - US3 Workout History
//

import SwiftUI
import SwiftData

/// Main progress view with segmented control for Workout and Exercise history
struct ProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()
    @State private var selectedSegment: HistorySegment = .workouts
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control
            Picker("Histórico", selection: $selectedSegment) {
                ForEach(HistorySegment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            .pickerStyle(.segmented)
            .padding()
            
            // Content based on selection
            switch selectedSegment {
            case .workouts:
                WorkoutHistoryListView()
            case .exercises:
                ExerciseHistoryListView()
            }
        .navigationTitle("Progresso")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.loadWorkoutHistory(context: modelContext)
            viewModel.loadExerciseHistory(context: modelContext)
        }

/// Segment options for history view
enum HistorySegment: String, CaseIterable {
    case workouts = "Treinos"
    case exercises = "Exercícios"
}

// MARK: - Preview


    .modelContainer(for: [WorkoutSession.self, WorkoutPlan.self, Exercise.self, ExerciseSet.self])
}


    .modelContainer(for: [WorkoutSession.self, WorkoutPlan.self, Exercise.self, ExerciseSet.self])
    .onAppear {
        // Simulate starting on exercises tab
        _ = HistorySegment.exercises
    }
