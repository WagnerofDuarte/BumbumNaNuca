//
//  EditWorkoutPlanViewModel.swift
//  BumbumNaNuca
//
//  ViewModel para edição de plano existente
//

import SwiftUI
import SwiftData

@Observable
final class EditWorkoutPlanViewModel {
    var name: String
    var description: String
    
    init(plan: WorkoutPlan) {
        self.name = plan.name
        self.description = plan.desc
    }
    
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
    
    func savePlan(_ plan: WorkoutPlan) -> Bool {
        guard canSave else { return false }
        
        plan.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        plan.desc = description.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return true
    }
}
