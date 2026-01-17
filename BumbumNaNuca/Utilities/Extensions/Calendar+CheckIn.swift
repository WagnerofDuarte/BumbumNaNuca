//
//  Calendar+CheckIn.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow
//

import Foundation

extension Calendar {
    /// Retorna o início do mês para uma data específica
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    /// Retorna o fim do mês para uma data específica (último segundo do último dia)
    func endOfMonth(for date: Date) -> Date {
        guard let nextMonth = self.date(byAdding: .month, value: 1, to: startOfMonth(for: date)) else {
            return date
        }
        return self.date(byAdding: .second, value: -1, to: nextMonth)!
    }
    
    /// Retorna todos os dias do mês como array de Dates
    func daysInMonth(for date: Date) -> [Date] {
        guard let monthRange = range(of: .day, in: .month, for: date) else {
            return []
        }
        
        let startOfMonth = self.startOfMonth(for: date)
        
        return monthRange.compactMap { day in
            self.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
}
