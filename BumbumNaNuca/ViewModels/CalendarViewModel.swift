//
//  CalendarViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 4
//

import SwiftUI
import SwiftData
import Foundation

/// Gerencia dados para visualização de calendários históricos
@Observable
final class CalendarViewModel {
    // MARK: - Published State
    
    /// Meses com check-ins agrupados (mais recente primeiro)
    var monthsWithCheckIns: [(month: Date, checkIns: [Date: CheckIn])] = []
    
    /// Estado de carregamento
    var isLoading: Bool = false
    
    // MARK: - Private Dependencies
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public Actions
    
    /// Carrega todos os meses com check-ins
    func loadAllMonths() {
        isLoading = true
        
        // Buscar todos os check-ins
        let descriptor = FetchDescriptor<CheckIn>(
            sortBy: [SortDescriptor(\CheckIn.date, order: .reverse)]
        )
        
        do {
            let allCheckIns = try modelContext.fetch(descriptor)
            
            // Agrupar por mês
            let calendar = Calendar.current
            var grouped: [Date: [CheckIn]] = [:]
            
            for checkIn in allCheckIns {
                let startOfMonth = calendar.startOfMonth(for: checkIn.date)
                if grouped[startOfMonth] == nil {
                    grouped[startOfMonth] = []
                }
                grouped[startOfMonth]?.append(checkIn)
            }
            
            // Filtrar meses vazios e criar tuplas
            monthsWithCheckIns = grouped
                .map { (month, checkIns) in
                    // Para cada mês, agrupar por dia (mostrar apenas o mais recente)
                    var dailyCheckIns: [Date: CheckIn] = [:]
                    for checkIn in checkIns {
                        let day = checkIn.calendarDay
                        if dailyCheckIns[day] == nil {
                            dailyCheckIns[day] = checkIn
                        }
                    }
                    return (month: month, checkIns: dailyCheckIns)
                }
                .filter { !$0.checkIns.isEmpty }
                .sorted { $0.month > $1.month } // Mais recente primeiro
            
        } catch {
            monthsWithCheckIns = []
        }
        
        isLoading = false
    }
}
