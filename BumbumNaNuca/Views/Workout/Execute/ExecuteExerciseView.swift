//
//  ExecuteExerciseView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI
import SwiftData
import OSLog

struct ExecuteExerciseView: View {
    let exercise: Exercise
    let session: WorkoutSession
    let onComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: ExecuteExerciseViewModel?
    @State private var timerViewModel: RestTimerViewModel?
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            if let viewModel = viewModel {
                exerciseContent(viewModel: viewModel)
            } else {
                ProgressView()
                    .onAppear {
                        self.viewModel = ExecuteExerciseViewModel(
                            exercise: exercise,
                            session: session,
                            modelContext: modelContext
                        )
                    }
            }
        }
        .navigationTitle("Executar Série")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Finalizar exercício", isPresented: Binding(
            get: { viewModel?.showingEarlyFinishAlert ?? false },
            set: { viewModel?.showingEarlyFinishAlert = $0 }
        )) {
            Button("Cancelar", role: .cancel) {}
            Button("Finalizar") {
                viewModel?.finish()
                onComplete()
                dismiss()
            }
        } message: {
            if let vm = viewModel {
                Text("Você completou apenas \(vm.currentSetNumber - 1) de \(vm.exercise.defaultSets) séries. Deseja finalizar mesmo assim?")
            }
        }
        .alert("Erro", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    @ViewBuilder
    private func exerciseContent(viewModel: ExecuteExerciseViewModel) -> some View {
        @Bindable var vm = viewModel
        
        VStack(spacing: 24) {
            // Top: Exercise information header
            ExerciseInfoHeader(exercise: exercise)
                .padding(.horizontal)
            
            Spacer()
            
            // Middle: Timer (when running) or Progress indicator + Inputs
            if let timer = timerViewModel, timer.isRunning {
                TimerDisplay(viewModel: timer)
            } else {
                VStack(spacing: 24) {
                    ProgressIndicator(
                        current: viewModel.currentSetNumber,
                        total: exercise.defaultSets
                    )
                    
                    // Input fields for load and reps
                    SetInputFields(
                        loadText: $vm.loadText,
                        repsText: $vm.repsText,
                        loadError: viewModel.loadError,
                        repsError: viewModel.repsError,
                        onLoadChange: { viewModel.validateLoad() },
                        onRepsChange: { viewModel.validateReps() }
                    )
                    .padding(.horizontal)
                }
            }
            
            Spacer()
            
            // Bottom: Action button
            PrimaryButton(
                title: buttonTitle(for: viewModel),
                action: {
                    if timerViewModel?.isRunning == true {
                        // Skip rest and go to next set
                        skipRest()
                    } else if shouldFinish(viewModel) {
                        attemptFinish(viewModel)
                    } else {
                        startRestPeriod(viewModel)
                    }
                }
            )
            .disabled(!viewModel.isInputValid && timerViewModel?.isRunning != true && !shouldFinish(viewModel))
            .padding(.horizontal)
            .padding(.bottom, 32)
        }
    }
    
    private func buttonTitle(for viewModel: ExecuteExerciseViewModel) -> String {
        if timerViewModel?.isRunning == true {
            return "Pular Descanso"
        } else if viewModel.currentSetNumber > exercise.defaultSets {
            return "Finalizar Exercício"
        } else {
            return "Começar Descanso"
        }
    }
    
    private func shouldFinish(_ viewModel: ExecuteExerciseViewModel) -> Bool {
        return viewModel.currentSetNumber > exercise.defaultSets
    }
    
    private func startRestPeriod(_ viewModel: ExecuteExerciseViewModel) {
        // Record set automatically
        do {
            try viewModel.recordSet()
            
            // Start rest timer if not last set
            if !shouldFinish(viewModel) {
                let restTime = exercise.defaultRestTime > 0 ? exercise.defaultRestTime : 60
                timerViewModel = RestTimerViewModel(duration: TimeInterval(restTime))
                timerViewModel?.start()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    
    private func attemptFinish(_ viewModel: ExecuteExerciseViewModel) {
        viewModel.attemptFinish()
        
        // If no alert shown (all sets complete), finish immediately
        if !viewModel.showingEarlyFinishAlert {
            onComplete()
            dismiss()
        }
    }
    
    private func skipRest() {
        // Stop the timer and move to next set
        timerViewModel?.stop()
        timerViewModel = nil
    }
}

/// Progress indicator showing current set number
struct ProgressIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Série \(current) de \(total)")
                .font(.title2.bold())
            
            HStack(spacing: 8) {
                ForEach(1...total, id: \.self) { setNumber in
                    Circle()
                        .fill(setNumber < current ? Color.green : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
        }
        .padding()
    }
}

#Preview("ExecuteExerciseView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: WorkoutPlan.self, Exercise.self, WorkoutSession.self, ExerciseSet.self,
        configurations: config
    )
    
    let plan = WorkoutPlan(name: "Treino A")
    let exercise = Exercise(
        name: "Supino Reto",
        muscleGroup: .chest,
        defaultSets: 4,
        defaultReps: 12,
        defaultRestTime: 90,
        load: 60.0
    )
    let session = WorkoutSession()
    session.workoutPlan = plan
    
    container.mainContext.insert(plan)
    container.mainContext.insert(exercise)
    container.mainContext.insert(session)
    
    return NavigationStack {
        ExecuteExerciseView(exercise: exercise, session: session, onComplete: {})
    }
    .modelContainer(container)
}

#Preview("ProgressIndicator") {
    ProgressIndicator(current: 2, total: 4)
}
