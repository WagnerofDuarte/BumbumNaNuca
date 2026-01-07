//
//  WorkoutSummaryViewModel.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import Foundation
import Observation

@Observable
final class WorkoutSummaryViewModel {
    // MARK: - Properties
    
    private let session: WorkoutSession
    
    private(set) var duration: TimeInterval
    private(set) var completedExercisesCount: Int
    private(set) var totalSets: Int
    private(set) var totalReps: Int
    
    // MARK: - Computed Properties
    
    var formattedDuration: String {
        duration.toFormattedDuration()
    }
    
    // MARK: - Initialization
    
    init(session: WorkoutSession) {
        self.session = session
        
        // Calculate summary
        self.duration = session.duration ?? 0
        self.completedExercisesCount = session.completedExercises.count
        self.totalSets = session.totalSets
        self.totalReps = session.totalReps
    }
}
