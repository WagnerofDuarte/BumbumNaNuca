//
//  Exercise.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData

@Model
final class Exercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var muscleGroup: MuscleGroup
    var defaultSets: Int
    var defaultReps: Int
    var defaultRestTime: Int  // em segundos
    var order: Int  // posição no plano (para drag & drop)
    var load: Double?  // carga em kg (opcional - nil para peso corporal)
    
    var workoutPlan: WorkoutPlan?
    
    init(
        id: UUID = UUID(),
        name: String,
        muscleGroup: MuscleGroup,
        defaultSets: Int = 3,
        defaultReps: Int = 12,
        defaultRestTime: Int = 60,
        order: Int = 0,
        load: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.defaultSets = defaultSets
        self.defaultReps = defaultReps
        self.defaultRestTime = defaultRestTime
        self.order = order
        self.load = load
    }
}
