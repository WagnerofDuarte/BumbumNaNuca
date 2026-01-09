//
//  WorkoutPlanListView.swift
//  BumbumNaNuca
//
//  View principal listando todos os planos de treino
//

import SwiftUI
import SwiftData

struct WorkoutPlanListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WorkoutPlan.createdDate, order: .reverse) private var allPlans: [WorkoutPlan]
    @State private var viewModel = WorkoutPlanListViewModel()
    
    private var filteredPlans: [WorkoutPlan] {
        viewModel.filteredPlans(allPlans)
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredPlans.isEmpty {
                    if viewModel.searchText.isEmpty {
                        EmptyStateView(
                            icon: "list.bullet.clipboard",
                            title: "Nenhum Plano",
                            message: "Crie seu primeiro plano de treino para começar",
                            actionTitle: "Criar Plano",
                            action: viewModel.showCreateSheet
                        )
                    } else {
                        ContentUnavailableView.search(text: viewModel.searchText)
                    }
                } else {
                    List {
                        ForEach(filteredPlans) { plan in
                            WorkoutPlanRowView(plan: plan)
                        }
                        .onDelete(perform: deletePlans)
                    }
                    .navigationDestination(for: WorkoutPlan.self) { plan in
                        WorkoutPlanDetailView(plan: plan)
                    }
                }
            }
            .navigationTitle("Meus Planos")
            .searchable(text: $viewModel.searchText, prompt: "Buscar planos")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        viewModel.showCreateSheet()
                    } label: {
                        Label("Criar Plano", systemImage: "plus")
                    }
                }
                
                if !allPlans.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $viewModel.isShowingCreateSheet) {
                CreateWorkoutPlanView()
            }
        }
    }
    
    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            let plan = filteredPlans[index]
            modelContext.delete(plan)
        }
    }
}

#Preview("Empty") {
    WorkoutPlanListView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}

#Preview("With Data") {
    let container = try! ModelContainer(
        for: WorkoutPlan.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    
    let plan1 = WorkoutPlan(name: "Treino A", description: "Peito e Tríceps")
    let plan2 = WorkoutPlan(name: "Treino B", description: "Costas e Bíceps")
    let plan3 = WorkoutPlan(name: "Treino C", description: "Pernas")
    
    container.mainContext.insert(plan1)
    container.mainContext.insert(plan2)
    container.mainContext.insert(plan3)
    
    return WorkoutPlanListView()
        .modelContainer(container)
}
