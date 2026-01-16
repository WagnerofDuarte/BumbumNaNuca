//
//  ExerciseType.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow
//

import SwiftUI

/// Helper para tipos de exercício predefinidos
struct ExerciseType {
    /// Lista completa de tipos de exercício disponíveis
    static let all: [String] = [
        "Corrida",
        "Musculação",
        "Natação",
        "Ciclismo",
        "Caminhada",
        "Yoga",
        "Treino de Força",
        "Funcional"
    ]
    
    /// Valida se o tipo de exercício é válido
    static func isValid(_ type: String) -> Bool {
        return all.contains(type)
    }
    
    /// Retorna o ícone SF Symbol e cor associados ao tipo de exercício
    static func icon(for type: String) -> (symbol: String, color: Color) {
        switch type {
        case "Corrida":
            return ("figure.run", .orange)
        case "Musculação":
            return ("dumbbell.fill", .red)
        case "Natação":
            return ("figure.pool.swim", .blue)
        case "Ciclismo":
            return ("bicycle", .green)
        case "Caminhada":
            return ("figure.walk", .teal)
        case "Yoga":
            return ("figure.mind.and.body", .purple)
        case "Treino de Força":
            return ("figure.strengthtraining.traditional", .pink)
        case "Funcional":
            return ("figure.mixed.cardio", .indigo)
        default:
            return ("figure.mixed.cardio", .gray)
        }
    }
}
