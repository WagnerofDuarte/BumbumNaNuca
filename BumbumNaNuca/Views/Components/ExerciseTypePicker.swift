//
//  ExerciseTypePicker.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow
//

import SwiftUI

/// Seletor de tipo de exercício com ícones coloridos
struct ExerciseTypePicker: View {
    @Binding var selectedType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tipo de Exercício")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(ExerciseType.all, id: \.self) { type in
                    ExerciseTypeButton(
                        type: type,
                        isSelected: selectedType == type,
                        action: { selectedType = type }
                    )
                }
            }
        }
    }
}

/// Botão individual para tipo de exercício
private struct ExerciseTypeButton: View {
    let type: String
    let isSelected: Bool
    let action: () -> Void
    
    private var iconConfig: (symbol: String, color: Color) {
        ExerciseType.icon(for: type)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(iconConfig.color)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconConfig.symbol)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                Text(type)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(height: 32)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Exercise Type Picker") {
    struct PreviewWrapper: View {
        @State private var selectedType = "Gym"
        
        var body: some View {
            ScrollView {
                ExerciseTypePicker(selectedType: $selectedType)
                    .padding()
                
                Text("Selecionado: \(selectedType)")
                    .font(.headline)
                    .padding()
            }
        }
    }
    
    return PreviewWrapper()
}
