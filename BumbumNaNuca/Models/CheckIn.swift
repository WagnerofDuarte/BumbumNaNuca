//
//  CheckIn.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftData
import Foundation

@Model
final class CheckIn {
    /// Identificador único
    @Attribute(.unique) var id: UUID
    
    /// Data e hora completa do check-in (timestamp preciso)
    var date: Date
    
    /// Observações opcionais (não usado no MVP, preparação para futuro)
    var notes: String
    
    /// Relacionamento opcional com treino executado após check-in
    /// deleteRule .nullify: se WorkoutSession for deletada, CheckIn permanece
    @Relationship(deleteRule: .nullify)
    var workoutSession: WorkoutSession?
    
    init(id: UUID = UUID(), date: Date = Date(), notes: String = "") {
        self.id = id
        self.date = date
        self.notes = notes
    }
}
