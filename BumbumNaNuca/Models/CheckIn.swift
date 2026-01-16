//
//  CheckIn.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftData
import Foundation
import UIKit
import OSLog

@Model
final class CheckIn {
    /// Identificador único
    @Attribute(.unique) var id: UUID
    
    /// Data e hora completa do check-in (timestamp preciso)
    var date: Date
    
    /// Observações opcionais (não usado no MVP, preparação para futuro)
    var notes: String
    
    // MARK: - Feature 005: Register Check-In with Photo
    
    /// Foto do treino comprimida em formato JPEG
    var photoData: Data?
    
    /// Tipo de exercício (Run, Gym, Swim, Bike, Walk, Yoga, Cycling, Strength Training)
    var exerciseType: String = "Unknown"
    
    /// Título do check-in (obrigatório, max 100 caracteres)
    var title: String = "Legacy Check-in"
    
    /// Calorias queimadas (opcional)
    var calories: Int?
    
    /// Localização do treino (opcional, texto livre)
    var location: String?
    
    /// Relacionamento opcional com treino executado após check-in
    /// deleteRule .nullify: se WorkoutSession for deletada, CheckIn permanece
    @Relationship(deleteRule: .nullify)
    var workoutSession: WorkoutSession?
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        notes: String = "",
        photoData: Data? = nil,
        exerciseType: String = "Unknown",
        title: String = "Legacy Check-in",
        calories: Int? = nil,
        location: String? = nil
    ) {
        self.id = id
        self.date = date
        self.notes = notes
        self.photoData = photoData
        self.exerciseType = exerciseType
        self.title = title
        self.calories = calories
        self.location = location
    }
}

// MARK: - Computed Properties

extension CheckIn {
    /// Retorna UIImage a partir dos dados da foto comprimida
    var photo: UIImage? {
        guard let data = photoData else { return nil }
        
        // Tenta criar imagem, retorna nil se dados corrompidos
        guard let image = UIImage(data: data) else {
            AppLogger.checkIn.error("Dados de imagem corrompidos para check-in: \(self.id.uuidString)")
            return nil
        }
        
        return image
    }
    
    /// Retorna thumbnail (100x100pt) para exibição em calendário
    var thumbnail: UIImage? {
        guard let photo = photo else { return nil }
        let targetSize = CGSize(width: 100, height: 100)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0)
        photo.draw(in: CGRect(origin: .zero, size: targetSize))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail
    }
    
    /// Retorna o dia do calendário (início do dia, sem hora) para agrupamento
    var calendarDay: Date {
        Calendar.current.startOfDay(for: date)
    }
}
