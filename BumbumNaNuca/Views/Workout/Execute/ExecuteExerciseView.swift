//
//  ExecuteExerciseView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI
import SwiftData

struct ExecuteExerciseView: View {
    let exercise: Exercise
    let session: WorkoutSession
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ExecuteExerciseViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel {
                exerciseContent(viewModel: viewModel)
            } else {
                ProgressView("Carregando...")
                    .onAppear {
                        self.viewModel = ExecuteExerciseViewModel(
                            exercise: exercise,
                            session: session,
                            modelContext: modelContext
                        )
                    }
            }
        }
    }
    
    @ViewBuilder
    private func exerciseContent(viewModel: ExecuteExerciseViewModel) -> some View {
        NavigationStack {
            Form {
                // Last workout reference
                if let lastData = viewModel.lastWorkoutData {
                    Section {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lastData.formattedText)
                                    .font(.subheadline)
                                Text(lastData.date.toRelativeString())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                
                // Progress indicator
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(viewModel.progressText)
                            .font(.headline)
                        
                        if viewModel.hasReachedDefaultSets {
                            Label("Meta de séries atingida! Pode continuar se quiser.", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                // Input section
                Section("Nova Série") {
                    ExerciseInputContent(viewModel: viewModel, recordSet: recordSet)
                }
                
                // Completed sets
                if !viewModel.completedSets.isEmpty {
                    Section("Séries Completadas (\(viewModel.completedSets.count))") {
                        ForEach(viewModel.completedSets) { set in
                            HStack {
                                Text("Série \(set.setNumber)")
                                    .font(.subheadline)
                                Spacer()
                                Text(set.formattedWeight)
                                    .foregroundColor(.secondary)
                                Text("×")
                                    .foregroundColor(.secondary)
                                Text("\(set.reps) reps")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluir Exercício") {
                        completeExercise()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Voltar") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func recordSet() {
        guard let viewModel = viewModel else { return }
        
        do {
            let _ = try viewModel.recordSet()
            viewModel.clearInputs()
        } catch {
            print("Error recording set: \(error)")
        }
    }
    
    private func completeExercise() {
        onComplete()
    }
}

// Auxiliary component to handle @Bindable
private struct ExerciseInputContent: View {
    @Bindable var viewModel: ExecuteExerciseViewModel
    let recordSet: () -> Void
    
    var body: some View {
        SetInputView(
            weightText: $viewModel.weightText,
            repsText: $viewModel.repsText,
            weightError: viewModel.weightError,
            repsError: viewModel.repsError,
            onWeightChange: { viewModel.validateWeight() },
            onRepsChange: { viewModel.validateReps() }
        )
        
        Button(action: recordSet) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Concluir Série")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(!viewModel.isFormValid)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutPlan.self, Exercise.self, WorkoutSession.self, ExerciseSet.self,
        configurations: config
    )
    
    let plan = WorkoutPlan(name: "Treino A")
    let exercise = Exercise(name: "Supino Reto", muscleGroup: .chest, defaultSets: 4, defaultReps: 12)
    let session = WorkoutSession()
    session.workoutPlan = plan
    
    container.mainContext.insert(plan)
    container.mainContext.insert(exercise)
    container.mainContext.insert(session)
    
    return ExecuteExerciseView(exercise: exercise, session: session, onComplete: {})
        .modelContainer(container)
}
