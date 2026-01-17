//
//  HomeViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftData
import Foundation
import Observation

@Observable
final class HomeViewModel {
    // MARK: - Properties
    
    /// Planos de treino marcados como favoritos
    var favoritePlans: [WorkoutPlan] = []
    
    /// Última sessão de treino completada
    var lastCompletedWorkout: WorkoutSession?
    
    /// Check-in de hoje (se existir)
    var todayCheckIn: CheckIn?
    
    /// Sequência atual de check-ins consecutivos
    var currentStreak: Int = 0
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    /// Indica se existem planos favoritos
    var hasFavoritePlans: Bool {
        !favoritePlans.isEmpty
    }
    
    /// Indica se já fez check-in hoje
    var hasCheckInToday: Bool {
        todayCheckIn != nil
    }
    
    /// Texto do botão de check-in
    var checkInButtonText: String {
        hasCheckInToday ? "Check-in realizado ✓" : "Fazer Check-in"
    }
    
    /// Horário do check-in de hoje (formatado)
    var checkInTimeText: String? {
        todayCheckIn?.date.toTimeString()
    }
    
    // MARK: - Actions
    
    /// Carrega todos os dados do dashboard
    /// - Parameter context: ModelContext para queries SwiftData
    func loadDashboard(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        // Buscar planos favoritos
        favoritePlans = fetchFavoritePlans(context: context)
        
        // Buscar último treino completado
        lastCompletedWorkout = fetchLastCompletedWorkout(context: context)
        
        // Buscar check-in de hoje
        todayCheckIn = fetchTodayCheckIn(context: context)
        
        // Calcular sequência (usa últimos 30 check-ins para performance)
        currentStreak = calculateCurrentStreak(context: context)
    }
    
    /// Executa check-in rápido do dashboard
    /// - Parameter context: ModelContext para insert
    func performQuickCheckIn(context: ModelContext) {
        guard todayCheckIn == nil else { return }
        
        let checkIn = CheckIn(date: Date())
        context.insert(checkIn)
        
        // Atualizar propriedade local
        todayCheckIn = checkIn
        
        // Recalcular sequência
        currentStreak = calculateCurrentStreak(context: context)
    }
    
    // MARK: - Private Helpers
    
    private func fetchFavoritePlans(context: ModelContext) -> [WorkoutPlan] {
        let descriptor = FetchDescriptor<WorkoutPlan>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
    
    private func fetchLastCompletedWorkout(context: ModelContext) -> WorkoutSession? {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted == true },
            sortBy: [SortDescriptor(\WorkoutSession.startDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }
    
    private func fetchTodayCheckIn(context: ModelContext) -> CheckIn? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { checkIn in
                checkIn.date >= startOfDay && checkIn.date < endOfDay
            }
        )
        return try? context.fetch(descriptor).first
    }
    
    private func calculateCurrentStreak(context: ModelContext) -> Int {
        var descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        descriptor.fetchLimit = 30  // Performance: limitar busca
        
        guard let checkIns = try? context.fetch(descriptor) else { return 0 }
        
        let dates = checkIns.map { $0.date }
        return CheckInStreak.calculateStreak(from: dates)
    }
}
