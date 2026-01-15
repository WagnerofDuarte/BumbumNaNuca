//
//  ExerciseInfoHeader.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 10/01/26.
//

import SwiftUI

/// Displays exercise information (name, muscle group, sets, reps, load, rest time)
struct ExerciseInfoHeader: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise name
            Text(exercise.name)
                .font(.title.bold())
            
            // Muscle group
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                Text(exercise.muscleGroup.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // Configuration details
            HStack(spacing: 16) {
                InfoPill(icon: "repeat", text: "\(exercise.defaultSets) séries")
                InfoPill(icon: "arrow.up.arrow.down", text: "\(exercise.defaultReps) reps")
                
                if let load = exercise.load {
                    InfoPill(icon: "scalemass", text: String(format: "%.1f kg", load))
                }
                
                InfoPill(icon: "timer", text: "\(exercise.defaultRestTime)s")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

/// Small pill-shaped info display with icon and text
struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

#Preview("ExerciseInfoHeader - With Load") {
    ExerciseInfoHeader(
        exercise: Exercise(
            name: "Agachamento",
            muscleGroup: .legs,
            defaultSets: 4,
            defaultReps: 10,
            defaultRestTime: 90,
            load: 60.0
        )
    )
    .padding()
}

#Preview("ExerciseInfoHeader - No Load") {
    ExerciseInfoHeader(
        exercise: Exercise(
            name: "Flexão",
            muscleGroup: .chest,
            defaultSets: 3,
            defaultReps: 15,
            defaultRestTime: 60
        )
    )
    .padding()
}
