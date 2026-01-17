//
//  AddExerciseViewModel.swift
//  BumbumNaNuca
//
//  ViewModel para adicionar novo exercício ao plano
//

import SwiftUI
import SwiftData

@Observable
final class AddExerciseViewModel {
    var name: String = ""
    var muscleGroup: MuscleGroup = .chest
    var sets: Int = 3
    var reps: Int = 12
    var restTime: Int = 60
    var loadText: String = ""
    
    init(exercise: Exercise? = nil) {
        if let exercise = exercise {
            // Populate fields with existing exercise data
            self.name = exercise.name
            self.muscleGroup = exercise.muscleGroup
            self.sets = exercise.defaultSets
            self.reps = exercise.defaultReps
            self.restTime = exercise.defaultRestTime
            self.loadText = exercise.load.map { String($0) } ?? ""
        }
    }
    
    // Validações
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var loadError: String? {
        guard !loadText.isEmpty else { return nil }
        
        if let load = Double(loadText), load > 0 {
            return nil
        }
        return "Carga deve ser um número positivo"
    }
    
    var canSave: Bool {
        isNameValid && sets > 0 && reps > 0 && restTime > 0 && loadError == nil
    }
    
    // Mensagens de validação
    var nameErrorMessage: String? {
        if name.isEmpty {
            return nil
        }
        return isNameValid ? nil : "Nome não pode ser vazio"
    }
    
    func addExercise(to plan: WorkoutPlan, context: ModelContext) -> Exercise? {
        guard canSave else { return nil }
        
        // Parse load (nil if empty)
        let load: Double? = loadText.isEmpty ? nil : Double(loadText)
        
        // Calcular próxima ordem baseada no número de exercícios existentes
        let nextOrder = plan.exercises.count
        
        let exercise = Exercise(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            muscleGroup: muscleGroup,
            defaultSets: sets,
            defaultReps: reps,
            defaultRestTime: restTime,
            order: nextOrder,
            load: load
        )
        
        exercise.workoutPlan = plan
        context.insert(exercise)
        
        return exercise
    }
    
    func updateExercise(_ exercise: Exercise, context: ModelContext) {
        guard canSave else { return }
        
        // Parse load (nil if empty)
        let load: Double? = loadText.isEmpty ? nil : Double(loadText)
        
        // Update exercise properties
        exercise.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        exercise.muscleGroup = muscleGroup
        exercise.defaultSets = sets
        exercise.defaultReps = reps
        exercise.defaultRestTime = restTime
        exercise.load = load
    }
    
    func reset() {
        name = ""
        muscleGroup = .chest
        sets = 3
        reps = 12
        restTime = 60
        loadText = ""
    }
}
