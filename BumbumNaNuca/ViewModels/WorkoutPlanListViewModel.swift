//
//  WorkoutPlanListViewModel.swift
//  BumbumNaNuca
//
//  ViewModel para gerenciar a lista de planos de treino
//

import SwiftUI
import SwiftData

@Observable
final class WorkoutPlanListViewModel {
    var searchText: String = ""
    var isShowingCreateSheet: Bool = false
    
    // Computed property para filtrar planos baseado na busca
    func filteredPlans(_ plans: [WorkoutPlan]) -> [WorkoutPlan] {
        if searchText.isEmpty {
            return plans
        }
        
        return plans.filter { plan in
            plan.name.localizedCaseInsensitiveContains(searchText) ||
            plan.desc.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    func showCreateSheet() {
        isShowingCreateSheet = true
    }
    
    func hideCreateSheet() {
        isShowingCreateSheet = false
    }
}
