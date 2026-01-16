//
//  AddExerciseView.swift
//  BumbumNaNuca
//
//  View para adicionar exercício ao plano
//

import SwiftUI
import SwiftData

struct AddExerciseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddExerciseViewModel
    
    let plan: WorkoutPlan
    let exerciseToEdit: Exercise?
    
    init(plan: WorkoutPlan, exerciseToEdit: Exercise? = nil) {
        self.plan = plan
        self.exerciseToEdit = exerciseToEdit
        _viewModel = State(initialValue: AddExerciseViewModel(exercise: exerciseToEdit))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Informações do Exercício") {
                    TextField("Nome", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                    
                    if let errorMessage = viewModel.nameErrorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    Picker("Grupo Muscular", selection: $viewModel.muscleGroup) {
                        ForEach(MuscleGroup.allCases, id: \.self) { group in
                            HStack {
                                Image(systemName: group.iconName)
                                Text(group.rawValue)
                            }
                            .tag(group)
                        }
                    }
                }
                
                Section("Séries e Repetições") {
                    Stepper("Séries: \(viewModel.sets)", value: $viewModel.sets, in: 1...10)
                    Stepper("Repetições: \(viewModel.reps)", value: $viewModel.reps, in: 1...50)
                }
                
                Section {
                    TextField("Carga (kg)", text: $viewModel.loadText)
                        .keyboardType(.decimalPad)
                    
                    if let error = viewModel.loadError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    
                    Text("Deixe em branco para exercícios de peso corporal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Carga")
                }
                
                Section("Descanso") {
                    Stepper("Descanso: \(viewModel.restTime)s", value: $viewModel.restTime, in: 15...300, step: 15)
                    
                    Text("Recomendado: 30-60s para hipertrofia, 60-180s para força")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(exerciseToEdit == nil ? "Novo Exercício" : "Editar Exercício")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(exerciseToEdit == nil ? "Adicionar" : "Salvar") {
                        if exerciseToEdit == nil {
                            if let _ = viewModel.addExercise(to: plan, context: modelContext) {
                                dismiss()
                            }
                        } else {
                            viewModel.updateExercise(exerciseToEdit!, context: modelContext)
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
    }
}

#Preview {
    AddExerciseView(plan: WorkoutPlan(name: "Treino A", description: "Peito e Tríceps"))
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
