//
//  ProgressViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftData
import Foundation
import Observation

@Observable
final class ProgressViewModel {
    // MARK: - Types
    
    enum ProgressTab: String, CaseIterable {
        case workouts = "Treinos"
        case exercises = "Exercícios"
    }
    
    // MARK: - Properties
    
    /// Tab selecionada (Treinos ou Exercícios)
    var selectedTab: ProgressTab = .workouts
    
    /// Lista de treinos completados (limit 50 para performance)
    var completedSessions: [WorkoutSession] = []
    
    /// Lista de exercícios já executados com estatísticas
    var executedExercises: [ExerciseStats] = []
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Actions
    
    /// Carrega histórico de treinos
    func loadWorkoutHistory(context: ModelContext, limit: Int = 50) {
        isLoading = true
        defer { isLoading = false }
        
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted == true },
            sortBy: [SortDescriptor(\WorkoutSession.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        descriptor.relationshipKeyPathsForPrefetching = [\WorkoutSession.exerciseSets]
        
        completedSessions = (try? context.fetch(descriptor)) ?? []
    }
    
    /// Carrega histórico de exercícios com estatísticas
    func loadExerciseHistory(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        // Buscar todas as séries executadas
        let setsDescriptor = FetchDescriptor<ExerciseSet>(
            sortBy: [SortDescriptor(\ExerciseSet.completedDate, order: .reverse)]
        )
        
        guard let allSets = try? context.fetch(setsDescriptor) else {
            executedExercises = []
            return
        }
        
        // Agrupar por exercício
        var exerciseDict: [String: [ExerciseSet]] = [:]
        for set in allSets {
            guard let exerciseName = set.exercise?.name else { continue }
            exerciseDict[exerciseName, default: []].append(set)
        }
        
        // Calcular estatísticas por exercício
        executedExercises = exerciseDict.map { name, sets in
            let sortedSets = sets.sorted { $0.completedDate > $1.completedDate }
            let lastExecution = sortedSets.first?.completedDate ?? Date()
            let personalRecord = calculatePersonalRecord(from: sortedSets)
            
            return ExerciseStats(
                exerciseName: name,
                lastExecutionDate: lastExecution,
                totalSetsExecuted: sortedSets.count,
                personalRecord: personalRecord
            )
        }.sorted { $0.lastExecutionDate > $1.lastExecutionDate }
    }
    
    // MARK: - Private Helpers
    
    private func calculatePersonalRecord(from sets: [ExerciseSet]) -> PersonalRecord? {
        guard !sets.isEmpty else { return nil }
        
        // Encontrar maior peso
        guard let maxWeightSet = sets.max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }),
              let maxWeight = maxWeightSet.weight
        else { return nil }
        
        // Entre séries com mesmo peso máximo, pegar maior reps
        let maxWeightSets = sets.filter { $0.weight == maxWeight }
        guard let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps }) else {
            return nil
        }
        
        return PersonalRecord(
            weight: maxWeight,
            reps: bestSet.reps,
            date: bestSet.completedDate
        )
    }
}

// MARK: - Supporting Types

struct ExerciseStats: Identifiable {
    let exerciseName: String
    let lastExecutionDate: Date
    let totalSetsExecuted: Int
    let personalRecord: PersonalRecord?
    
    var id: String { exerciseName }
}

struct PersonalRecord {
    let weight: Double
    let reps: Int
    let date: Date
    
    var formattedRecord: String {
        String(format: "%.1fkg × %d", weight, reps)
    }
}
