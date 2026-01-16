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
    var editingExercise: Exercise? = nil
    
    func toggleFavorite(plan: WorkoutPlan, context: ModelContext) {
        // Simplesmente inverte o estado de favorito
        plan.isFavorite.toggle()
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
        editingExercise = nil
        isShowingAddExerciseSheet = true
    }
    
    func hideAddExerciseSheet() {
        isShowingAddExerciseSheet = false
        editingExercise = nil
    }
    
    func showEditExercise(_ exercise: Exercise) {
        editingExercise = exercise
        isShowingAddExerciseSheet = true
    }
}
