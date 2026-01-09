//
//  CreateWorkoutPlanView.swift
//  BumbumNaNuca
//
//  View para criar novo plano de treino
//

import SwiftUI
import SwiftData

struct CreateWorkoutPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CreateWorkoutPlanViewModel()
    
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
            .navigationTitle("Novo Plano")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Criar") {
                        if let _ = viewModel.createPlan(context: modelContext) {
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
    CreateWorkoutPlanView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
