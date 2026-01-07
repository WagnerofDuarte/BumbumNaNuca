//
//  WorkoutSessionViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class WorkoutSessionViewModel {
    // MARK: - Properties
    
    private(set) var session: WorkoutSession?
    private(set) var exercises: [Exercise] = []
    private(set) var completedExercises: Set<UUID> = []
    private(set) var error: SessionError?
    
    private let workoutPlan: WorkoutPlan
    private let modelContext: ModelContext
    
    // MARK: - Computed Properties
    
    var progressPercentage: Double {
        guard !exercises.isEmpty else { return 0 }
        return Double(completedExercises.count) / Double(exercises.count)
    }
    
    var progressText: String {
        "\(completedExercises.count)/\(exercises.count) exercícios completos"
    }
    
    var isSessionActive: Bool {
        session?.endDate == nil
    }
    
    // MARK: - Initialization
    
    init(workoutPlan: WorkoutPlan, modelContext: ModelContext) {
        self.workoutPlan = workoutPlan
        self.modelContext = modelContext
        self.exercises = workoutPlan.exercises.sorted { $0.order < $1.order }
    }
    
    // MARK: - Session Management
    
    func startSession() throws {
        // Verificar se já existe sessão ativa
        if let existingSession = try? checkExistingSession() {
            throw SessionError.sessionAlreadyExists(existingSession)
        }
        
        // Criar nova sessão
        let newSession = WorkoutSession(startDate: Date())
        newSession.workoutPlan = workoutPlan
        
        modelContext.insert(newSession)
        
        do {
            try modelContext.save()
            self.session = newSession
        } catch {
            throw SessionError.persistenceError(error)
        }
    }
    
    func finalizeSession() throws {
        guard let session = session else {
            throw SessionError.invalidWorkoutPlan
        }
        
        session.endDate = Date()
        session.isCompleted = true
        
        do {
            try session.validate()
            try modelContext.save()
        } catch {
            throw SessionError.persistenceError(error)
        }
    }
    
    func resumeSession(_ existingSession: WorkoutSession) {
        self.session = existingSession
        
        // Atualizar exercícios completados com base nas séries
        completedExercises = existingSession.completedExercises
    }
    
    func abandonSession(_ existingSession: WorkoutSession) throws {
        existingSession.endDate = Date()
        existingSession.isCompleted = true
        
        do {
            try modelContext.save()
        } catch {
            throw SessionError.persistenceError(error)
        }
    }
    
    // MARK: - Exercise Management
    
    func markExerciseComplete(_ exercise: Exercise) {
        completedExercises.insert(exercise.id)
    }
    
    func isExerciseComplete(_ exercise: Exercise) -> Bool {
        completedExercises.contains(exercise.id)
    }
    
    func exerciseStatus(_ exercise: Exercise) -> ExerciseStatus {
        guard let session = session else { return .pending }
        
        // Verificar se tem séries registradas
        let hasSets = session.exerciseSets.contains { $0.exercise?.id == exercise.id }
        
        if completedExercises.contains(exercise.id) {
            return .completed
        } else if hasSets {
            return .inProgress
        } else {
            return .pending
        }
    }
    
    // MARK: - Query
    
    private func checkExistingSession() throws -> WorkoutSession? {
        let planId = workoutPlan.id
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { session in
                session.workoutPlan?.id == planId &&
                session.isCompleted == false
            },
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
    
    // MARK: - Types
    
    enum ExerciseStatus {
        case pending
        case inProgress
        case completed
    }
    
    enum SessionError: LocalizedError {
        case sessionAlreadyExists(WorkoutSession)
        case invalidWorkoutPlan
        case persistenceError(Error)
        
        var errorDescription: String? {
            switch self {
            case .sessionAlreadyExists:
                return "Já existe uma sessão ativa para este plano"
            case .invalidWorkoutPlan:
                return "Plano de treino inválido"
            case .persistenceError(let error):
                return "Erro ao salvar: \(error.localizedDescription)"
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .sessionAlreadyExists:
                return "Retome a sessão existente ou finalize-a antes de iniciar uma nova"
            default:
                return nil
            }
        }
    }
}
