//
//  WorkoutSession.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var startDate: Date
    var endDate: Date?
    var isCompleted: Bool
    var notes: String
    
    var workoutPlan: WorkoutPlan?
    
    @Relationship(deleteRule: .cascade)
    var exerciseSets: [ExerciseSet]
    
    init(
        id: UUID = UUID(),
        startDate: Date = Date(),
        endDate: Date? = nil,
        isCompleted: Bool = false,
        notes: String = ""
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.isCompleted = isCompleted
        self.notes = notes
        self.exerciseSets = []
    }
    
    // MARK: - Validation
    
    func validate() throws {
        if isCompleted && endDate == nil {
            throw ValidationError.incompleteDateMissing
        }
        if let end = endDate, end < startDate {
            throw ValidationError.endBeforeStart
        }
    }
    
    // MARK: - Computed Properties
    
    var duration: TimeInterval? {
        guard let end = endDate else { return nil }
        return end.timeIntervalSince(startDate)
    }
    
    var totalSets: Int {
        exerciseSets.count
    }
    
    var totalReps: Int {
        exerciseSets.reduce(0) { $0 + $1.reps }
    }
    
    var completedExercises: Set<UUID> {
        Set(exerciseSets.compactMap { $0.exercise?.id })
    }
}

// MARK: - Validation Errors

enum ValidationError: LocalizedError {
    case incompleteDateMissing
    case endBeforeStart
    case invalidWeight
    case invalidReps
    case invalidDefaultSets
    case invalidDefaultReps
    case invalidRestTime
    
    var errorDescription: String? {
        switch self {
        case .incompleteDateMissing:
            return "Sessão completa deve ter data de término"
        case .endBeforeStart:
            return "Data de término não pode ser anterior à data de início"
        case .invalidWeight:
            return "Peso deve ser maior que zero"
        case .invalidReps:
            return "Repetições devem ser maior que zero"
        case .invalidDefaultSets:
            return "Número de séries deve estar entre 1 e 10"
        case .invalidDefaultReps:
            return "Número de repetições deve estar entre 1 e 50"
        case .invalidRestTime:
            return "Tempo de descanso deve estar entre 0 e 300 segundos"
        }
    }
}
