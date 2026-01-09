//
//  WorkoutHistoryListView.swift
//  BumbumNaNuca
//
//  Created by speckit.implement on 2026
//  Feature: 003-mvp-completion - US3 Workout History
//

import SwiftUI
import SwiftData

/// List of completed workout sessions ordered by date descending
struct WorkoutHistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ProgressViewModel()
    @Query(
        filter: #Predicate<WorkoutSession> { $0.endDate != nil },
        sort: \WorkoutSession.startDate,
        order: .reverse
    ) private var completedSessions: [WorkoutSession]
    
    var body: some View {
        Group {
            if completedSessions.isEmpty {
                // Empty state
                EmptyStateView(
                    icon: "figure.walk",
                    title: "Nenhum treino concluído",
                    message: "Complete seu primeiro treino para ver o histórico aqui"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(completedSessions) { session in
                            NavigationLink(value: session) {
                                WorkoutHistoryRowView(session: session)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
                .navigationDestination(for: WorkoutSession.self) { session in
                    SessionDetailView(session: session)
                }
            }
        }
        .onAppear {
            viewModel.loadWorkoutHistory(context: modelContext)
        }
    }
}
