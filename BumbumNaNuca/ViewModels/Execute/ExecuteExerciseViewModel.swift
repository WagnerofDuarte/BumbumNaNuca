//
//  ExecuteExerciseViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData
import Observation
import OSLog

@Observable
final class ExecuteExerciseViewModel {
    // MARK: - Properties
    
    let exercise: Exercise
    private let session: WorkoutSession
    private let modelContext: ModelContext
    
    // Set tracking
    private(set) var completedSets: [ExerciseSet] = []
    private(set) var currentSetNumber: Int = 1
    
    // Input state (valores atuais para próxima série)
    var loadText: String = ""
    var repsText: String = ""
    
    // Validation
    var loadError: String? = nil
    var repsError: String? = nil
    
    // Alert state
    var showingEarlyFinishAlert = false
    
    // MARK: - Computed Properties
    
    var isLastSet: Bool {
        currentSetNumber > exercise.defaultSets
    }
    
    var progressText: String {
        "Série \(currentSetNumber) de \(exercise.defaultSets)"
    }
    
    var setsRemaining: Int {
        max(0, exercise.defaultSets - (currentSetNumber - 1))
    }
    
    var isInputValid: Bool {
        loadError == nil && repsError == nil && !repsText.isEmpty
    }
    
    // MARK: - Initialization
    
    init(exercise: Exercise, session: WorkoutSession, modelContext: ModelContext) {
        self.exercise = exercise
        self.session = session
        self.modelContext = modelContext
        
        loadCompletedSets()
        resetInputsForNextSet()
    }
    
    // MARK: - Set Management
    
    @discardableResult
    func recordSet() throws -> ExerciseSet {
        // Parse inputs
        let load: Double? = loadText.isEmpty ? nil : Double(loadText.replacingOccurrences(of: ",", with: "."))
        let reps = Int(repsText) ?? exercise.defaultReps
        
        let set = ExerciseSet(
            setNumber: currentSetNumber,
            weight: load,
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
            currentSetNumber += 1
            
            // Reset inputs for next set
            resetInputsForNextSet()
            
            AppLogger.execution.info("Recorded set \(set.setNumber) with \(reps) reps @ \(load ?? 0)kg for exercise \(self.exercise.name)")
            
            return set
        } catch {
            AppLogger.execution.error("Failed to record set: \(error.localizedDescription)")
            throw SetRecordingError.persistenceError(error)
        }
    }
    
    // MARK: - Exercise Completion
    
    func attemptFinish() {
        if currentSetNumber <= exercise.defaultSets {
            // Show alert: "Você completou apenas X de Y séries"
            showingEarlyFinishAlert = true
        } else {
            finish()
        }
    }
    
    func finish() {
        AppLogger.execution.info("Exercise \(self.exercise.name) finished with \(self.completedSets.count) sets")
        // Exercise marked complete (handled by parent view/ViewModel)
    }
    
    func canFinish() -> Bool {
        return completedSets.count > 0
    }
    
    // MARK: - Input Validation
    
    func validateLoad() {
        guard !loadText.isEmpty else {
            loadError = nil
            return
        }
        
        if let load = Double(loadText.replacingOccurrences(of: ",", with: ".")), load > 0 {
            loadError = nil
        } else {
            loadError = "Carga deve ser maior que 0"
        }
    }
    
    func validateReps() {
        guard !repsText.isEmpty else {
            repsError = "Repetições obrigatórias"
            return
        }
        
        if let reps = Int(repsText), reps > 0 {
            repsError = nil
        } else {
            repsError = "Deve ser um número maior que 0"
        }
    }
    
    private func resetInputsForNextSet() {
        // Pre-fill with exercise defaults for next set
        if let load = exercise.load {
            loadText = String(format: "%.1f", load)
        } else {
            loadText = ""
        }
        repsText = "\(exercise.defaultReps)"
        loadError = nil
        repsError = nil
    }
    
    // MARK: - Query
    
    private func loadCompletedSets() {
        // Load already completed sets from this session for this exercise
        completedSets = session.exerciseSets.filter { $0.exercise?.id == exercise.id }
            .sorted { $0.setNumber < $1.setNumber }
        
        if !completedSets.isEmpty {
            currentSetNumber = completedSets.count + 1
        }
    }
    
    // MARK: - Types
    
    enum SetRecordingError: LocalizedError {
        case persistenceError(Error)
        
        var errorDescription: String? {
            switch self {
            case .persistenceError(let error):
                return "Erro ao salvar: \(error.localizedDescription)"
            }
        }
    }
}
