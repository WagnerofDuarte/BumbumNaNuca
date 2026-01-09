//
//  CheckInViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftData
import Foundation
import Observation

@Observable
final class CheckInViewModel {
    // MARK: - Properties
    
    /// Check-in de hoje (se existir)
    var todayCheckIn: CheckIn?
    
    /// Sequência atual de dias consecutivos
    var currentStreak: Int = 0
    
    /// Melhor sequência já alcançada (recorde pessoal)
    var longestStreak: Int = 0
    
    /// Estatísticas do mês atual
    var monthlyStats: MonthlyStats = MonthlyStats(totalCheckIns: 0, totalDaysInMonth: 0)
    
    /// Últimos 30 check-ins para exibição
    var recentCheckIns: [CheckIn] = []
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Computed Properties
    
    /// Pode fazer check-in hoje?
    var canCheckInToday: Bool {
        todayCheckIn == nil
    }
    
    /// Texto do botão de check-in
    var checkInButtonText: String {
        if let checkIn = todayCheckIn {
            return "Check-in feito às \(checkIn.date.toTimeString())"
        }
        return "Fazer Check-in"
    }
    
    // MARK: - Actions
    
    /// Carrega todos os dados da tela de check-in
    func loadCheckInData(context: ModelContext) {
        isLoading = true
        defer { isLoading = false }
        
        // Check-in de hoje
        todayCheckIn = fetchTodayCheckIn(context: context)
        
        // Últimos check-ins (para calcular sequências e stats)
        recentCheckIns = fetchRecentCheckIns(context: context, limit: 60)
        
        // Calcular sequências
        let dates = recentCheckIns.map { $0.date }
        currentStreak = CheckInStreak.calculateStreak(from: dates)
        longestStreak = calculateLongestStreak(from: dates)
        
        // Estatísticas mensais
        monthlyStats = calculateMonthlyStats(from: recentCheckIns)
    }
    
    /// Executa check-in
    /// - Parameter context: ModelContext para insert
    /// - Returns: true se sucesso, false se já fez hoje
    @discardableResult
    func performCheckIn(context: ModelContext) -> Bool {
        guard canCheckInToday else { return false }
        
        let checkIn = CheckIn(date: Date())
        context.insert(checkIn)
        
        // Atualizar estado local
        todayCheckIn = checkIn
        recentCheckIns.insert(checkIn, at: 0)
        
        // Recalcular sequências e stats
        let dates = recentCheckIns.map { $0.date }
        currentStreak = CheckInStreak.calculateStreak(from: dates)
        longestStreak = max(longestStreak, currentStreak)
        monthlyStats = calculateMonthlyStats(from: recentCheckIns)
        
        return true
    }
    
    // MARK: - Private Helpers
    
    private func fetchTodayCheckIn(context: ModelContext) -> CheckIn? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<CheckIn>(
            predicate: #Predicate { $0.date >= startOfDay && $0.date < endOfDay }
        )
        return try? context.fetch(descriptor).first
    }
    
    private func fetchRecentCheckIns(context: ModelContext, limit: Int) -> [CheckIn] {
        var descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return (try? context.fetch(descriptor)) ?? []
    }
    
    private func calculateLongestStreak(from dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        let calendar = Calendar.current
        let uniqueDays = Set(dates.map { calendar.startOfDay(for: $0) }).sorted(by: >)
        
        var longestStreak = 0
        var currentStreak = 0
        var expectedDate: Date?
        
        for day in uniqueDays {
            if let expected = expectedDate {
                if day == expected {
                    currentStreak += 1
                } else {
                    longestStreak = max(longestStreak, currentStreak)
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            expectedDate = calendar.date(byAdding: .day, value: -1, to: day)
        }
        
        return max(longestStreak, currentStreak)
    }
    
    private func calculateMonthlyStats(from checkIns: [CheckIn]) -> MonthlyStats {
        let calendar = Calendar.current
        let now = Date()
        
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let range = calendar.range(of: .day, in: .month, for: now)
        else {
            return MonthlyStats(totalCheckIns: 0, totalDaysInMonth: 0)
        }
        
        let totalDaysInMonth = range.count
        
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let monthlyCheckIns = checkIns.filter { checkIn in
            checkIn.date >= startOfMonth && checkIn.date <= endOfMonth
        }
        
        return MonthlyStats(
            totalCheckIns: monthlyCheckIns.count,
            totalDaysInMonth: totalDaysInMonth
        )
    }
}

// MARK: - Supporting Types

struct MonthlyStats {
    let totalCheckIns: Int
    let totalDaysInMonth: Int
    
    var percentage: Double {
        guard totalDaysInMonth > 0 else { return 0 }
        return (Double(totalCheckIns) / Double(totalDaysInMonth)) * 100
    }
    
    var formattedPercentage: String {
        String(format: "%.0f%%", percentage)
    }
}
