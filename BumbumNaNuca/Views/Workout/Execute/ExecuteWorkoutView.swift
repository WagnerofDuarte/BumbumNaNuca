//
//  ExecuteWorkoutView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI
import SwiftData

struct ExecuteWorkoutView: View {
    let workoutPlan: WorkoutPlan
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigateToHome) private var navigateToHome
    
    @State private var viewModel: WorkoutSessionViewModel?
    @State private var selectedExercise: Exercise?
    @State private var showingSummary = false
    @State private var showingCancelAlert = false
    @State private var showingSessionConflict = false
    @State private var existingSession: WorkoutSession?
    @State private var error: WorkoutSessionViewModel.SessionError?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                workoutContent(viewModel: viewModel)
            } else {
                ProgressView()
                    .onAppear {
                        initializeSession()
                    }
            }
        }
        .alert("Sessão Existente", isPresented: $showingSessionConflict) {
            Button("Retomar", role: .none) {
                if let existing = existingSession {
                    viewModel?.resumeSession(existing)
                }
            }
            Button("Abandonar e Iniciar Nova", role: .destructive) {
                if let existing = existingSession {
                    try? viewModel?.abandonSession(existing)
                    try? viewModel?.startSession()
                }
            }
            Button("Cancelar", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("Você já tem uma sessão de treino ativa para este plano. Deseja retomá-la ou iniciar uma nova?")
        }
        .alert("Erro", isPresented: .constant(error != nil)) {
            Button("OK") {
                error = nil
                dismiss()
            }
        } message: {
            if let error = error {
                Text(error.localizedDescription)
            }
        }
    }
    
    @ViewBuilder
    private func workoutContent(viewModel: WorkoutSessionViewModel) -> some View {
        VStack(spacing: 0) {
            // Progress header
            ProgressHeader(
                progress: viewModel.progressPercentage,
                text: viewModel.progressText
            )
            .padding()
            
            // Exercise list
            List {
                ForEach(viewModel.exercises) { exercise in
                    ExerciseExecutionRow(
                        exercise: exercise,
                        status: viewModel.exerciseStatus(exercise)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedExercise = exercise
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle(workoutPlan.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancelar") {
                    showingCancelAlert = true
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Button("Finalizar") {
                    finalizeWorkout()
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            if let session = viewModel.session {
                ExecuteExerciseView(
                    exercise: exercise,
                    session: session,
                    onComplete: {
                        viewModel.markExerciseComplete(exercise)
                        selectedExercise = nil
                    }
                )
            }
        }
        .navigationDestination(isPresented: $showingSummary) {
            if let session = viewModel.session {
                WorkoutSummaryView(session: session, onFinish: {
                    navigateToHome()
                })
            }
        }
        .alert("Cancelar Treino", isPresented: $showingCancelAlert) {
            Button("Continuar Treino", role: .cancel) {}
            Button("Cancelar Treino", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("Suas séries registradas serão salvas automaticamente")
        }
    }
    
    private func initializeSession() {
        let vm = WorkoutSessionViewModel(workoutPlan: workoutPlan, modelContext: modelContext)
        
        do {
            try vm.startSession()
            self.viewModel = vm
        } catch WorkoutSessionViewModel.SessionError.sessionAlreadyExists(let existing) {
            self.existingSession = existing
            self.viewModel = vm
            showingSessionConflict = true
        } catch {
            self.error = error as? WorkoutSessionViewModel.SessionError
        }
    }
    
    private func finalizeWorkout() {
        guard let viewModel = viewModel else { return }
        
        do {
            try viewModel.finalizeSession()
            showingSummary = true
        } catch {
            self.error = error as? WorkoutSessionViewModel.SessionError
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutPlan.self, Exercise.self, WorkoutSession.self, ExerciseSet.self,
        configurations: config
    )
    
    let plan = WorkoutPlan(name: "Treino A - Peito e Tríceps")
    plan.exercises = [
        Exercise(name: "Supino Reto", muscleGroup: .chest, defaultSets: 4, defaultReps: 12),
        Exercise(name: "Supino Inclinado", muscleGroup: .chest, defaultSets: 3, defaultReps: 10),
        Exercise(name: "Tríceps Testa", muscleGroup: .arms, defaultSets: 3, defaultReps: 12)
    ]
    container.mainContext.insert(plan)
    
    return ExecuteWorkoutView(workoutPlan: plan)
        .modelContainer(container)
}
