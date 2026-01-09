//
//  Logger.swift
//  BumbumNaNuca
//
//  Logging estruturado conforme Constitution Principle IV
//

import Foundation
import OSLog

/// Logger centralizado para o app BumbumNaNuca
/// Usage: Logger.workout.info("Treino iniciado")
enum AppLogger {
    private static let subsystem = "com.app.BumbumNaNuca"
    
    /// Logger para features relacionadas a treinos
    static let workout = Logger(subsystem: subsystem, category: "workout")
    
    /// Logger para features de execução de treino
    static let execution = Logger(subsystem: subsystem, category: "execution")
    
    /// Logger para features de check-in
    static let checkIn = Logger(subsystem: subsystem, category: "checkin")
    
    /// Logger para features de progresso
    static let progress = Logger(subsystem: subsystem, category: "progress")
    
    /// Logger para UI e navegação
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Logger para persistência de dados
    static let data = Logger(subsystem: subsystem, category: "data")
}
