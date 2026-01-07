//
//  ExerciseExecutionRow.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI

struct ExerciseExecutionRow: View {
    let exercise: Exercise
    let status: WorkoutSessionViewModel.ExerciseStatus
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                Text(exercise.muscleGroup.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(exercise.defaultSets) séries × \(exercise.defaultReps) reps")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Status badge
            statusBadge
        }
        .padding(.vertical, 8)
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
    
    @ViewBuilder
    private var statusBadge: some View {
        switch status {
        case .pending:
            EmptyView()
        case .inProgress:
            Image(systemName: "arrow.right.circle.fill")
                .foregroundColor(.blue)
                .imageScale(.large)
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .imageScale(.large)
        }
    }
}

#Preview {
    let exercise = Exercise(
        name: "Supino Reto",
        muscleGroup: .chest,
        defaultSets: 4,
        defaultReps: 12
    )
    
    List {
        ExerciseExecutionRow(exercise: exercise, status: .pending)
        ExerciseExecutionRow(exercise: exercise, status: .inProgress)
        ExerciseExecutionRow(exercise: exercise, status: .completed)
    }
}
