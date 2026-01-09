//
//  ExecuteExerciseViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData
import Observation

@Observable
final class ExecuteExerciseViewModel {
    // MARK: - Properties
    
    private let exercise: Exercise
    private let session: WorkoutSession
    private let modelContext: ModelContext
    
    // Input state
    var weightText: String = ""
    var repsText: String = ""
    
    // Validation
    private(set) var weightError: String?
    private(set) var repsError: String?
    
    // Series tracking
    private(set) var completedSets: [ExerciseSet] = []
    private(set) var lastWorkoutData: LastWorkoutData?
    
    // Timer state
    var showRestTimer: Bool = false
    var shouldCancelTimer: Bool = false
    
    // MARK: - Computed Properties
    
    var currentSetNumber: Int {
        completedSets.count + 1
    }
    
    var isFormValid: Bool {
        weightError == nil && repsError == nil && !repsText.isEmpty
    }
    
    var progressText: String {
        "Série \(currentSetNumber) de \(exercise.defaultSets)"
    }
    
    var hasReachedDefaultSets: Bool {
        completedSets.count >= exercise.defaultSets
    }
    
    // MARK: - Initialization
    
    init(exercise: Exercise, session: WorkoutSession, modelContext: ModelContext) {
        self.exercise = exercise
        self.session = session
        self.modelContext = modelContext
        
        loadCompletedSets()
        fetchLastWorkoutData()
    }
    
    // MARK: - Validation
    
    func validateWeight() {
        guard !weightText.isEmpty else {
            weightError = nil  // Empty is valid (bodyweight)
            return
        }
        
        guard let weight = Double(weightText), weight > 0 else {
            weightError = "Peso deve ser positivo"
            return
        }
        
        weightError = nil
    }
    
    func validateReps() {
        guard let reps = Int(repsText), reps > 0 else {
            repsError = "Repetições devem ser maior que zero"
            return
        }
        
        repsError = nil
    }
    
    // MARK: - Set Management
    
    @discardableResult
    func recordSet() throws -> ExerciseSet {
        // Validate first
        validateWeight()
        validateReps()
        
        guard isFormValid else {
            throw SetRecordingError.invalidInput
        }
        
        guard let reps = Int(repsText) else {
            throw SetRecordingError.invalidReps
        }
        
        let weight = weightText.isEmpty ? nil : Double(weightText)
        
        let set = ExerciseSet(
            setNumber: currentSetNumber,
            weight: weight,
            reps: reps,
            completedDate: Date()
        )
        set.exercise = exercise
        set.session = session
        
        do {
            try set.validate()
            modelContext.insert(set)
            try modelContext.save()
            
            completedSets.append(set)
            
            return set
        } catch {
            throw SetRecordingError.persistenceError(error)
        }
    }
    
    func clearInputs() {
        weightText = ""
        repsText = ""
        weightError = nil
        repsError = nil
    }
    
    // MARK: - Timer Management
    
    func startRestTimer() {
        // Cancel any existing timer
        shouldCancelTimer = true
        
        // Show new timer
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.shouldCancelTimer = false
            self?.showRestTimer = true
        }
    }
    
    func hideRestTimer() {
        showRestTimer = false
    }
    
    func cancelRestTimer() {
        shouldCancelTimer = true
        showRestTimer = false
    }
    
    // MARK: - Query
    
    private func loadCompletedSets() {
        // Carregar séries já completadas desta sessão para este exercício
        completedSets = session.exerciseSets.filter { $0.exercise?.id == exercise.id }
            .sorted { $0.setNumber < $1.setNumber }
    }
    
    func fetchLastWorkoutData() {
        guard let workoutPlan = session.workoutPlan else { return }
        
        let planId = workoutPlan.id
        let exerciseId = exercise.id
        
        let descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { session in
                session.workoutPlan?.id == planId &&
                session.isCompleted == true
            },
            sortBy: [SortDescriptor(\.endDate, order: .reverse)]
        )
        
        do {
            let sessions = try modelContext.fetch(descriptor)
            
            // Buscar primeira sessão que tem sets deste exercício
            for pastSession in sessions {
                if let lastSet = pastSession.exerciseSets
                    .filter({ $0.exercise?.id == exerciseId })
                    .sorted(by: { $0.completedDate > $1.completedDate })
                    .first {
                    
                    lastWorkoutData = LastWorkoutData(
                        weight: lastSet.weight,
                        reps: lastSet.reps,
                        date: pastSession.endDate ?? pastSession.startDate
                    )
                    break
                }
            }
        } catch {
            // Fail silently - não é crítico
            print("Error fetching last workout data: \(error)")
        }
    }
    
    // MARK: - Types
    
    struct LastWorkoutData {
        let weight: Double?
        let reps: Int
        let date: Date
        
        var formattedText: String {
            let weightStr: String
            if let weight = weight {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 1
                formatter.locale = Locale.current
                
                let formattedWeight = formatter.string(from: NSNumber(value: weight)) ?? String(format: "%.1f", weight)
                weightStr = "\(formattedWeight) kg"
            } else {
                weightStr = "Peso corporal"
            }
            
            return "Último: \(weightStr) × \(reps) reps"
        }
    }
    
    enum SetRecordingError: LocalizedError {
        case invalidInput
        case invalidWeight
        case invalidReps
        case persistenceError(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidInput:
                return "Dados inválidos. Verifique os campos."
            case .invalidWeight:
                return "Peso inválido"
            case .invalidReps:
                return "Número de repetições inválido"
            case .persistenceError(let error):
                return "Erro ao salvar: \(error.localizedDescription)"
            }
        }
    }
}
