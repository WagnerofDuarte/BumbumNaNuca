//
//  WorkoutPlanDetailView.swift
//  BumbumNaNuca
//
//  View de detalhes do plano com lista de exercícios
//

import SwiftUI
import SwiftData

struct WorkoutPlanDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = WorkoutPlanDetailViewModel()
    
    let plan: WorkoutPlan
    
    private var sortedExercises: [Exercise] {
        plan.exercises.sorted { $0.order < $1.order }
    }
    
    var body: some View {
        List {
            // Seção de informações do plano
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(plan.name)
                            .font(.title2.weight(.bold))
                        
                        Spacer()
                        
                        if plan.isActive {
                            Text("ATIVO")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.green, in: Capsule())
                        }
                    }
                    
                    if !plan.desc.isEmpty {
                        Text(plan.desc)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("\(plan.exercises.count) exercícios", systemImage: "figure.strengthtraining.traditional")
                        
                        Spacer()
                        
                        Text("Criado \(plan.createdDate.toRelativeString())")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            // Botão de ativar/desativar
            Section {
                // Botão de Iniciar Treino
                NavigationLink {
                    ExecuteWorkoutView(workoutPlan: plan)
                } label: {
                    Label("Iniciar Treino", systemImage: "play.circle.fill")
                        .font(.headline)
                }
                .disabled(sortedExercises.isEmpty)
                .tint(.accentColor)
                
                Button {
                    viewModel.toggleActive(plan: plan, context: modelContext)
                } label: {
                    Label(
                        plan.isActive ? "Desativar Plano" : "Ativar Plano",
                        systemImage: plan.isActive ? "checkmark.circle.fill" : "circle"
                    )
                }
                .foregroundStyle(plan.isActive ? .red : .green)
            }
            
            // Lista de exercícios
            Section("Exercícios") {
                if sortedExercises.isEmpty {
                    ContentUnavailableView(
                        "Nenhum Exercício",
                        systemImage: "dumbbell",
                        description: Text("Adicione exercícios ao seu plano")
                    )
                } else {
                    ForEach(sortedExercises) { exercise in
                        ExerciseRowView(exercise: exercise)
                    }
                }
            }
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.showAddExerciseSheet()
                } label: {
                    Label("Adicionar Exercício", systemImage: "plus")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button {
                        viewModel.showEditSheet()
                    } label: {
                        Label("Editar Plano", systemImage: "pencil")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        viewModel.showDeleteAlert()
                    } label: {
                        Label("Excluir Plano", systemImage: "trash")
                    }
                } label: {
                    Label("Mais", systemImage: "ellipsis.circle")
                }
            }
        }
        .alert("Excluir Plano", isPresented: $viewModel.isShowingDeleteAlert) {
            Button("Cancelar", role: .cancel) {
                viewModel.hideDeleteAlert()
            }
            
            Button("Excluir", role: .destructive) {
                modelContext.delete(plan)
                dismiss()
            }
        } message: {
            Text("Tem certeza que deseja excluir \"\(plan.name)\"? Esta ação não pode ser desfeita.")
        }
        .sheet(isPresented: $viewModel.isShowingEditSheet) {
            EditWorkoutPlanView(plan: plan)
        }
        .sheet(isPresented: $viewModel.isShowingAddExerciseSheet) {
            AddExerciseView(plan: plan)
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutPlanDetailView(plan: {
            let plan = WorkoutPlan(name: "Treino A", description: "Peito e Tríceps")
            plan.isActive = true
            return plan
        }())
    }
    .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
