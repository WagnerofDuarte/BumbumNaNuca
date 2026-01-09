//
//  HomeView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.navigateToWorkout) private var navigateToWorkout
    
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header com saudação e data
                VStack(alignment: .leading, spacing: 8) {
                    Text("Olá, Atleta!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(Date().toHeaderString())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top)
                
                // Card de Check-in
                CheckInCard(
                    hasCheckInToday: viewModel.hasCheckInToday,
                    checkInTime: viewModel.checkInTimeText,
                    onCheckIn: {
                        viewModel.performQuickCheckIn(context: modelContext)
                    }
                )
                .padding(.horizontal)
                
                // Badge de Sequência
                if viewModel.currentStreak > 0 {
                    StreakBadge(streak: viewModel.currentStreak)
                }
                
                // Card de Plano Ativo
                if let plan = viewModel.activePlan {
                    activePlanCard(plan: plan)
                } else {
                    emptyPlanCard
                }
                
                // Card do Último Treino
                if let workout = viewModel.lastCompletedWorkout {
                    lastWorkoutCard(workout: workout)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Home")
        .onAppear {
            viewModel.loadDashboard(context: modelContext)
        }
        .refreshable {
            viewModel.loadDashboard(context: modelContext)
        }
    }
    
    // MARK: - Active Plan Card
    
    private func activePlanCard(plan: WorkoutPlan) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dumbbell.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Plano Ativo")
                        .font(.headline)
                    
                    Text(plan.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Button(action: {
                navigateToWorkout(plan)
            }) {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Iniciar Treino")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var emptyPlanCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "dumbbell")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Nenhum plano ativo")
                        .font(.headline)
                    
                    Text("Ative um plano para começar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Last Workout Card
    
    private func lastWorkoutCard(workout: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Último Treino")
                        .font(.headline)
                    
                    if let plan = workout.workoutPlan {
                        Text(plan.name)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(workout.startDate.toRelativeString())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if let endDate = workout.endDate {
                        let duration = endDate.timeIntervalSince(workout.startDate)
                        Text(duration.toFormattedDuration())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
