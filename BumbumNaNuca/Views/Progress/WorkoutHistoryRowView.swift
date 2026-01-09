//
//  WorkoutHistoryRowView.swift
//  BumbumNaNuca
//
//  Created by speckit.implement on 2026
//  Feature: 003-mvp-completion - US3 Workout History
//

import SwiftUI

/// Row component displaying workout session summary
struct WorkoutHistoryRowView: View {
    let session: WorkoutSession
    
    private var duration: String {
        guard let endTime = session.endTime else { return "Em andamento" }
        let interval = endTime.timeIntervalSince(session.startTime)
        let minutes = Int(interval) / 60
        return "\(minutes) min"
    }
    
    private var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(session.startTime) {
            return "Hoje"
        } else if calendar.isDateInYesterday(session.startTime) {
            return "Ontem"
        } else if let daysAgo = calendar.dateComponents([.day], from: session.startTime, to: now).day,
                  daysAgo < 7 {
            return "\(daysAgo) dias atrás"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: session.startTime)
        }
    
    private var exerciseCount: Int {
        session.completedExercises.count
    }
    
    private var totalSets: Int {
        session.completedExercises.reduce(0) { total, exercise in
            total + exercise.sets.count
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header: Plan name and time
            HStack {
                Text(String(session.workoutPlan?.name.prefix(2) ?? "🏋️"))
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(session.workoutPlan?.name ?? "Treino")
                        .font(.headline)
                    
                    Text(relativeDate)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Duration badge
                Text(duration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
            }
            
            // Stats: Exercises and Sets
            HStack(spacing: 16) {
                Label("\(exerciseCount) exercícios", systemImage: "figure.strengthtraining.traditional")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Label("\(totalSets) séries", systemImage: "list.number")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

// MARK: - Preview






