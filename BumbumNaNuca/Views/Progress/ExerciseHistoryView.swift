//
//  ExerciseHistoryView.swift
//  BumbumNaNuca
//
//  Created by speckit.implement on 2026
//  Feature: 003-mvp-completion - US4 Exercise History
//

import SwiftUI

/// Detail view showing personal record and all sets history for a specific exercise
struct ExerciseHistoryView: View {
    let exerciseName: String
    let allSets: [ExerciseSet]
    let viewModel: ProgressViewModel
    
    private var personalRecord: PersonalRecord? {
        guard !allSets.isEmpty else { return nil }
        
        // Encontrar maior peso
        guard let maxWeightSet = allSets.max(by: { ($0.weight ?? 0) < ($1.weight ?? 0) }),
              let maxWeight = maxWeightSet.weight
        else { return nil }
        
        // Entre séries com mesmo peso máximo, pegar maior reps
        let maxWeightSets = allSets.filter { $0.weight == maxWeight }
        guard let bestSet = maxWeightSets.max(by: { $0.reps < $1.reps }) else {
            return nil
        }
        
        return PersonalRecord(
            weight: maxWeight,
            reps: bestSet.reps,
            date: bestSet.completedDate
        )
    }
    
    private var totalVolume: Double {
        allSets.reduce(0.0) { total, set in
            total + (Double(set.reps) * (set.weight ?? 0))
        }
    }
    
    private var totalSets: Int {
        allSets.count
    }
    
    private var muscleGroup: String {
        allSets.first?.exercise?.muscleGroup.rawValue ?? ""
    }
    
    // Group sets by workout session
    private var sessionGroups: [(WorkoutSession, [ExerciseSet])] {
        let grouped = Dictionary(grouping: allSets) { $0.session }
        return grouped.compactMap { session, sets -> (WorkoutSession, [ExerciseSet])? in
            guard let session = session else { return nil }
            return (session, sets.sorted { $0.setNumber < $1.setNumber })
        }
        .sorted { $0.0.startDate > $1.0.startDate } // Most recent first
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header: Exercise info
                headerSection
                
                // History by session
                historySection
            }
            .padding()
        }
        .navigationTitle("Histórico do Exercício")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exerciseName)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(muscleGroup)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Stats summary
            if let pr = personalRecord {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Recorde Pessoal")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("\(pr.reps) × \(String(format: "%.0f", pr.weight)) kg")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(formatDate(pr.date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.yellow.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Additional stats
            HStack(spacing: 16) {
                StatBadge(
                    label: "Total de Séries",
                    value: "\(totalSets)",
                    icon: "list.number"
                )
                
                StatBadge(
                    label: "Volume Total",
                    value: String(format: "%.0f kg", totalVolume),
                    icon: "scalemass.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Histórico Completo")
                .font(.headline)
            
            if sessionGroups.isEmpty {
                EmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Sem histórico",
                    message: "Você ainda não realizou este exercício"
                )
            } else {
                ForEach(sessionGroups, id: \.0.id) { session, sets in
                    SessionSetsCard(session: session, sets: sets)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views

/// Small stat badge
private struct StatBadge: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.blue)
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

/// Card showing all sets from a specific session
private struct SessionSetsCard: View {
    let session: WorkoutSession
    let sets: [ExerciseSet]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sessionHeader
            setsGridView
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var sessionHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.workoutPlan?.name ?? "Treino")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(relativeDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(sets.count) séries")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var relativeDate: String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(session.startDate) {
            return "Hoje"
        } else if calendar.isDateInYesterday(session.startDate) {
            return "Ontem"
        } else if let daysAgo = calendar.dateComponents([.day], from: session.startDate, to: now).day,
                  daysAgo < 7 {
            return "\(daysAgo) dias atrás"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: session.startDate)
        }
    }
    
    private var setsGridView: some View {
        VStack(spacing: 0) {
            gridHeader
            Divider()
            gridRows
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var gridHeader: some View {
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
    }
    
    private var gridRows: some View {
        ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
            VStack(spacing: 0) {
                HStack {
                    Text("\(index + 1)")
                        .font(.body)
                        .frame(width: 50, alignment: .leading)
                    
                    Text("\(set.reps)")
                        .font(.body)
                        .frame(width: 60, alignment: .center)
                    
                    Text(String(format: "%.1f", set.weight ?? 0))
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                if index < sets.count - 1 {
                    Divider()
                }
            }
        }
    }
}
