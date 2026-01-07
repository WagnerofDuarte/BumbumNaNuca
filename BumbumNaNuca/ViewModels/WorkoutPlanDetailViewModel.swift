//
//  WorkoutPlanDetailViewModel.swift
//  BumbumNaNuca
//
//  ViewModel para visualização de detalhes do plano
//

import SwiftUI
import SwiftData

@Observable
final class WorkoutPlanDetailViewModel {
    var isShowingEditSheet: Bool = false
    var isShowingDeleteAlert: Bool = false
    var isShowingAddExerciseSheet: Bool = false
    
    func toggleActive(plan: WorkoutPlan, context: ModelContext) {
        // Se o plano já está ativo, apenas desativa
        if plan.isActive {
            plan.isActive = false
            return
        }
        
        // Buscar todos os planos e desativar o ativo atual
        let descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.isActive == true }
        )
        
        if let activePlans = try? context.fetch(descriptor) {
            for activePlan in activePlans {
                activePlan.isActive = false
            }
        }
        
        // Ativar o plano atual
        plan.isActive = true
    }
    
    func showEditSheet() {
        isShowingEditSheet = true
    }
    
    func hideEditSheet() {
        isShowingEditSheet = false
    }
    
    func showDeleteAlert() {
        isShowingDeleteAlert = true
    }
    
    func hideDeleteAlert() {
        isShowingDeleteAlert = false
    }
    
    func showAddExerciseSheet() {
        isShowingAddExerciseSheet = true
    }
    
    func hideAddExerciseSheet() {
        isShowingAddExerciseSheet = false
    }
}
