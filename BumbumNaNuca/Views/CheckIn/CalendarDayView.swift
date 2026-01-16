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
            
            // Número do dia sobreposto
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("\(Calendar.current.component(.day, from: day))")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(checkIn != nil ? .white : .secondary)
                        .padding(4)
                        .background(
                            checkIn != nil
                                ? Color.black.opacity(0.5)
                                : Color.clear
                        )
                        .clipShape(Circle())
                        .padding(2)
                }
            }
        }
        .frame(width: 44, height: 44)
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
