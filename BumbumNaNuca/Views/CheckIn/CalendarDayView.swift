//
//  CalendarDayView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 3
//

import SwiftUI

/// Exibe um dia do calendário com foto/ícone de check-in ou vazio
struct CalendarDayView: View {
    let day: Date
    let checkIn: CheckIn?
    
    var body: some View {
        Group {
            if let checkIn = checkIn {
                // Dia com check-in - torna clicável
                NavigationLink {
                    CheckInDetailView(checkIn: checkIn)
                } label: {
                    dayContent
                }
                .buttonStyle(.plain)
            } else {
                // Dia sem check-in - não clicável
                dayContent
            }
        }
        .frame(width: 44, height: 44)
    }
    
    private var dayContent: some View {
        ZStack {
            // Background: foto, ícone ou vazio
            if let checkIn = checkIn {
                if let thumbnail = checkIn.thumbnail {
                    // Mostra foto arredondada
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    // Mostra ícone placeholder
                    PlaceholderIconView(exerciseType: checkIn.exerciseType, size: 44)
                }
            } else {
                // Dia vazio
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 44, height: 44)
            }
            
            // Número do dia sobreposto (centralizado)
            Text("\(Calendar.current.component(.day, from: day))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(checkIn != nil ? .white : .primary)
                .shadow(color: checkIn != nil ? .black.opacity(0.5) : .clear, radius: 2, x: 0, y: 1)
        }
    }
}

#Preview("With Photo") {
    CalendarDayView(
        day: Date(),
        checkIn: CheckIn(
            date: Date(),
            photoData: nil,
            exerciseType: "Run",
            title: "Morning Run"
        )
    )
}

#Preview("Empty Day") {
    CalendarDayView(day: Date(), checkIn: nil)
}
