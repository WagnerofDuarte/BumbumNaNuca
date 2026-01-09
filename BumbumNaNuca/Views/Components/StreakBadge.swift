//
//  StreakBadge.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftUI

struct StreakBadge: View {
    let streak: Int
    let isLongest: Bool
    
    init(streak: Int, isLongest: Bool = false) {
        self.streak = streak
        self.isLongest = isLongest
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isLongest ? "star.fill" : "flame.fill")
                .font(.title3)
                .foregroundStyle(isLongest ? .yellow : .orange)
            
            Text("\(streak)")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(streak == 1 ? "dia" : "dias")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        StreakBadge(streak: 5)
        StreakBadge(streak: 14, isLongest: true)
        StreakBadge(streak: 1)
    }
    .padding()
}
