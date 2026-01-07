//
//  Date+Extensions.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation

extension Date {
    /// Formata a data como string relativa (ex: "Há 2 dias", "Hoje", "Ontem")
    func toRelativeString() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(self) {
            return "Hoje"
        } else if calendar.isDateInYesterday(self) {
            return "Ontem"
        } else {
            let components = calendar.dateComponents([.day], from: self, to: now)
            if let days = components.day, days > 0 {
                return "Há \(days) dia\(days == 1 ? "" : "s")"
            } else {
                // Data futura ou mesma data
                return "Hoje"
            }
        }
    }
    
    /// Formata a data como string curta (ex: "06/01/2026")
    func toShortString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
    
    /// Formata a data com hora (ex: "06/01/2026 às 14:30")
    func toFullString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: self)
    }
}
