//
//  MuscleGroup.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation

enum MuscleGroup: String, Codable, CaseIterable {
    case chest = "Peito"
    case back = "Costas"
    case legs = "Pernas"
    case shoulders = "Ombros"
    case arms = "Braços"
    case abs = "Abdômen"
    case cardio = "Cardio"
    
    /// Cor da tag para UI (nome do color do sistema iOS)
    var tagColor: String {
        switch self {
        case .chest: return "blue"
        case .back: return "green"
        case .legs: return "purple"
        case .shoulders: return "orange"
        case .arms: return "red"
        case .abs: return "yellow"
        case .cardio: return "pink"
        }
    }
    
    /// Ícone SF Symbol para o grupo muscular
    var iconName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.arms.open"
        case .legs: return "figure.walk"
        case .shoulders: return "figure.stand"
        case .arms: return "dumbbell"
        case .abs: return "figure.core.training"
        case .cardio: return "figure.run"
        }
    }
}
