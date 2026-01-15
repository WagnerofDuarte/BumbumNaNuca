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
    
    func reset() {
        name = ""
        muscleGroup = .chest
        sets = 3
        reps = 12
        restTime = 60
        loadText = ""
    }
}
