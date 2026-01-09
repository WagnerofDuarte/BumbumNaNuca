//
//  SessionDetailView.swift
//  BumbumNaNuca
//
//  Created by speckit.implement on 2026
//  Feature: 003-mvp-completion - US3 Workout History
//

import SwiftUI

/// Detail view showing all exercises and sets from a completed workout session
struct SessionDetailView: View {
    let session: WorkoutSession
    
    private var duration: String {
        guard let endTime = session.endTime else { return "Em andamento" }
        let interval = endTime.timeIntervalSince(session.startTime)
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes) min"
        }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: session.startTime)
    }
    
    private var totalSets: Int {
        session.completedExercises.reduce(0) { total, exercise in
            total + exercise.sets.count
        }
    
    private var totalVolume: Double {
        session.completedExercises.reduce(0.0) { total, exercise in
            total + exercise.sets.reduce(0.0) { exerciseTotal, set in
                exerciseTotal + (Double(set.reps) * set.weight)
            }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header: Session info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(String(session.workoutPlan?.name.prefix(2) ?? "🏋️"))
                            .font(.largeTitle)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.workoutPlan?.name ?? "Treino")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(formattedDate)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Stats summary
                    HStack(spacing: 20) {
                        StatItem(label: "Duração", value: duration, icon: "clock.fill")
                        StatItem(label: "Exercícios", value: "\(session.completedExercises.count)", icon: "figure.strengthtraining.traditional")
                        StatItem(label: "Séries", value: "\(totalSets)", icon: "list.number")
                    }
                    
                    // Total volume
                    if totalVolume > 0 {
                        HStack {
                            Image(systemName: "scalemass.fill")
                                .foregroundStyle(.blue)
                            Text("Volume total:")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(String(format: "%.0f kg", totalVolume))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 4)
                    }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Exercises list
                VStack(alignment: .leading, spacing: 16) {
                    Text("Exercícios Realizados")
                        .font(.headline)
                    
                    ForEach(session.completedExercises.sorted(by: { 
                        ($0.sets.first?.order ?? 0) < ($1.sets.first?.order ?? 0)
                    })) { exercise in
                        ExerciseDetailCard(exercise: exercise, session: session)
                    }
                
                // Notes (if any)
                if let notes = session.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Observações", systemImage: "note.text")
                            .font(.headline)
                        
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
            .padding()
        }
        .navigationTitle("Detalhes do Treino")
        .navigationBarTitleDisplayMode(.inline)
    }

// MARK: - Supporting Views

/// Small stat item for session summary
private struct StatItem: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .font(.title3)
            
            Text(value)
                .font(.headline)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

/// Card showing exercise details with all sets
private struct ExerciseDetailCard: View {
    let exercise: Exercise
    let session: WorkoutSession
    
    private var sets: [ExerciseSet] {
        exercise.sets
            .filter { $0.workoutSession?.id == session.id }
            .sorted { $0.order < $1.order }
    
    private var exerciseVolume: Double {
        sets.reduce(0.0) { total, set in
            total + (Double(set.reps) * set.weight)
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.headline)
                    
                    Text(exercise.muscleGroup.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Exercise volume
                if exerciseVolume > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(String(format: "%.0f kg", exerciseVolume))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text("volume")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
            
            // Sets table
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Série")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 50, alignment: .leading)
                    
                    Text("Reps")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 60, alignment: .center)
                    
                    Text("Peso (kg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                
                Divider()
                
                // Sets
                ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                    HStack {
                        Text("\(index + 1)")
                            .font(.body)
                            .frame(width: 50, alignment: .leading)
                        
                        Text("\(set.reps)")
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(width: 60, alignment: .center)
                        
                        Text(String(format: "%.1f", set.weight))
                            .font(.body)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    if index < sets.count - 1 {
                        Divider()
                    }
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

// MARK: - Preview


}


}
