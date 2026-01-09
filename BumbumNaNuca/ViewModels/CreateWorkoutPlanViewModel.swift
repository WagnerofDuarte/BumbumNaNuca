//
//  CreateWorkoutPlanViewModel.swift
//  BumbumNaNuca
//
//  ViewModel para criação de novos planos de treino
//

import SwiftUI
import SwiftData

@Observable
final class CreateWorkoutPlanViewModel {
    var name: String = ""
    var description: String = ""
    
    // Validações
    var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var canSave: Bool {
        isNameValid
    }
    
    // Mensagens de validação
    var nameErrorMessage: String? {
        if name.isEmpty {
            return nil
        }
        return isNameValid ? nil : "Nome não pode ser vazio"
    }
    
    func createPlan(context: ModelContext) -> WorkoutPlan? {
        guard canSave else { return nil }
        
        let plan = WorkoutPlan(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        context.insert(plan)
        return plan
    }
    
    func reset() {
        name = ""
        description = ""
    }
}
