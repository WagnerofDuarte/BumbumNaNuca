//
//  WorkoutPlan.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData

@Model
final class WorkoutPlan {
    @Attribute(.unique) var id: UUID
    var name: String
    var desc: String  // "description" é palavra reservada do SwiftData
    var createdDate: Date
    var isActive: Bool
    
    @Relationship(deleteRule: .cascade, inverse: \Exercise.workoutPlan)
    var exercises: [Exercise]
    
    @Relationship(deleteRule: .cascade)
    var workoutSessions: [WorkoutSession]
    
    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        createdDate: Date = Date(),
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.desc = description
        self.createdDate = createdDate
        self.isActive = isActive
        self.exercises = []
        self.workoutSessions = []
    }
    
    /// Computed property para facilitar acesso
    var description: String {
        get { desc }
        set { desc = newValue }
    }
}
