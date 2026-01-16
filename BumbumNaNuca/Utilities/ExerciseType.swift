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
        "Run",
        "Gym",
        "Swim",
        "Bike",
        "Walk",
        "Yoga",
        "Cycling",
        "Strength Training"
    ]
    
    /// Valida se o tipo de exercício é válido
    static func isValid(_ type: String) -> Bool {
        return all.contains(type)
    }
    
    /// Retorna o ícone SF Symbol e cor associados ao tipo de exercício
    static func icon(for type: String) -> (symbol: String, color: Color) {
        switch type {
        case "Run":
            return ("figure.run", .orange)
        case "Gym":
            return ("dumbbell.fill", .red)
        case "Swim":
            return ("figure.pool.swim", .blue)
        case "Bike":
            return ("bicycle", .green)
        case "Walk":
            return ("figure.walk", .teal)
        case "Yoga":
            return ("figure.mind.and.body", .purple)
        case "Cycling":
            return ("bicycle.circle.fill", .indigo)
        case "Strength Training":
            return ("figure.strengthtraining.traditional", .pink)
        default:
            return ("figure.mixed.cardio", .gray)
        }
    }
}
