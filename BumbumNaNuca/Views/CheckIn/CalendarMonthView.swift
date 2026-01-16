//
//  CalendarMonthView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 3
//

import SwiftUI

/// Exibe calendário mensal em grade 7x7 com fotos/ícones de check-ins
struct CalendarMonthView: View {
    let month: Date
    let checkIns: [Date: CheckIn]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 8) {
            // Cabeçalho com nomes dos dias da semana
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grade de dias
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth, id: \.self) { day in
                    if let day = day {
                        CalendarDayView(
                            day: day,
                            checkIn: checkIns[calendar.startOfDay(for: day)]
                        )
                    } else {
                        // Espaço vazio para alinhar semana
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    /// Símbolos curtos dos dias da semana (D S T Q Q S S)
    private var weekdaySymbols: [String] {
        calendar.veryShortWeekdaySymbols
    }
    
    /// Dias do mês incluindo espaços vazios para alinhamento
    private var daysInMonth: [Date?] {
        let startOfMonth = calendar.startOfMonth(for: month)
        
        // Dias vazios antes do primeiro dia do mês
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let emptyDays = Array(repeating: nil as Date?, count: firstWeekday - 1)
        
        // Dias do mês
        let daysArray = calendar.daysInMonth(for: month).map { Optional($0) }
        
        return emptyDays + daysArray
    }
}

#Preview("Current Month") {
    CalendarMonthView(
        month: Date(),
        checkIns: [
            Calendar.current.startOfDay(for: Date()): CheckIn(
                date: Date(),
                exerciseType: "Run",
                title: "Morning Run"
            )
        ]
    )
    .padding()
}
