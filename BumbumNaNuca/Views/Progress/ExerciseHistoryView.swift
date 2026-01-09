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
    let exercise: Exercise
    let viewModel: ProgressViewModel
    
    private var personalRecord: ProgressViewModel.PersonalRecord? {
        viewModel.calculatePersonalRecord(for: exercise)
    }
    
    private var totalVolume: Double {
        exercise.sets.reduce(0.0) { total, set in
            total + (Double(set.reps) * set.weight)
        }
    
    private var totalSets: Int {
        exercise.sets.count
    }
    
    // Group sets by workout session
    private var sessionGroups: [(WorkoutSession, [ExerciseSet])] {
        let grouped = Dictionary(grouping: exercise.sets) { $0.workoutSession }
        return grouped.compactMap { session, sets in
            guard let session = session else { return nil }
            return (session, sets.sorted { $0.order < $1.order })
        }
        .sorted { $0.0.startTime > $1.0.startTime } // Most recent first
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header: Exercise info
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(exercise.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(exercise.muscleGroup.rawValue)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    // Stats summary
                    HStack(spacing: 20) {
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
                                
                                if let date = pr.date {
                                    Text(formatDate(date))
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
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // History by session
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
            .padding()
        }
        .navigationTitle("Histórico do Exercício")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: date)
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

/// Card showing all sets from a specific session
private struct SessionSetsCard: View {
    let session: WorkoutSession
    let sets: [ExerciseSet]
    
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
            formatter.locale = Locale(identifier: "pt_BR")
            return formatter.string(from: session.startTime)
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Session header
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
            
            // Sets grid
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
                            .frame(width: 60, alignment: .center)
                        
                        Text(String(format: "%.1f", set.weight))
                            .font(.body)
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
