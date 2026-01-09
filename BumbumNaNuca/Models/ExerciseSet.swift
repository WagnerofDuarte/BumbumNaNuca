//
//  ExerciseSet.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import SwiftData

@Model
final class ExerciseSet {
    @Attribute(.unique) var id: UUID
    var setNumber: Int
    var weight: Double?  // nil = peso corporal
    var reps: Int
    var completedDate: Date
    var notes: String
    
    @Relationship(deleteRule: .nullify)
    var exercise: Exercise?
    
    var session: WorkoutSession?
    
    init(
        id: UUID = UUID(),
        setNumber: Int,
        weight: Double? = nil,
        reps: Int,
        completedDate: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.completedDate = completedDate
        self.notes = notes
    }
    
    // MARK: - Validation
    
    func validate() throws {
        guard reps > 0 else {
            throw ValidationError.invalidReps
        }
        if let w = weight, w <= 0 {
            throw ValidationError.invalidWeight
        }
    }
    
    // MARK: - Computed Properties
    
    var formattedWeight: String {
        guard let w = weight else { return "Peso corporal" }
        return String(format: "%.1f kg", w)
    }
    
    /// Fórmula de Brzycki para estimativa de 1RM
    var oneRepMax: Double? {
        guard let w = weight else { return nil }
        return w / (1.0278 - 0.0278 * Double(reps))
    }
}
