//
//  CheckInCard.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftUI

struct CheckInCard: View {
    let hasCheckInToday: Bool
    let checkInTime: String?
    let onCheckIn: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: hasCheckInToday ? "checkmark.circle.fill" : "calendar.badge.checkmark")
                    .font(.title2)
                    .foregroundStyle(hasCheckInToday ? .green : .blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Check-in")
                        .font(.headline)
                    
                    if hasCheckInToday, let time = checkInTime {
                        Text("Feito às \(time)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Registre sua presença")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                if !hasCheckInToday {
                    Button(action: onCheckIn) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 16) {
        CheckInCard(hasCheckInToday: false, checkInTime: nil, onCheckIn: {})
        CheckInCard(hasCheckInToday: true, checkInTime: "18:30", onCheckIn: {})
    }
    .padding()
}
