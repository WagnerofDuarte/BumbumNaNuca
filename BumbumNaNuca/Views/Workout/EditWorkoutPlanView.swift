//
//  EditWorkoutPlanView.swift
//  BumbumNaNuca
//
//  View para editar plano de treino existente
//

import SwiftUI
import SwiftData

struct EditWorkoutPlanView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: EditWorkoutPlanViewModel
    
    let plan: WorkoutPlan
    
    init(plan: WorkoutPlan) {
        self.plan = plan
        _viewModel = State(initialValue: EditWorkoutPlanViewModel(plan: plan))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome do Plano", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                    
                    if let errorMessage = viewModel.nameErrorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                
                Section("Descrição (Opcional)") {
                    TextField("Descrição", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .navigationTitle("Editar Plano")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if viewModel.savePlan(plan) {
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
    EditWorkoutPlanView(plan: WorkoutPlan(name: "Treino A", description: "Peito e Tríceps"))
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
