//
//  PlaceholderIconView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow
//

import SwiftUI

/// Exibe ícone arredondado colorido para tipo de exercício (quando não há foto)
struct PlaceholderIconView: View {
    let exerciseType: String
    var size: CGFloat = 44
    
    private var iconConfig: (symbol: String, color: Color) {
        ExerciseType.icon(for: exerciseType)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(iconConfig.color)
                .frame(width: size, height: size)
            
            Image(systemName: iconConfig.symbol)
                .font(.system(size: size * 0.55))
                .foregroundColor(.white)
        }
    }
}

#Preview("Gym Icon") {
    PlaceholderIconView(exerciseType: "Gym", size: 48)
}

#Preview("Run Icon") {
    PlaceholderIconView(exerciseType: "Run", size: 48)
}

#Preview("All Types") {
    VStack(spacing: 16) {
        ForEach(ExerciseType.all, id: \.self) { type in
            HStack {
                PlaceholderIconView(exerciseType: type, size: 44)
                Text(type)
                    .font(.body)
                Spacer()
            }
        }
    }
    .padding()
}
