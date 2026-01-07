//
//  WorkoutPlanRowView.swift
//  BumbumNaNuca
//
//  Componente de linha para exibir plano na lista
//

import SwiftUI

struct WorkoutPlanRowView: View {
    let plan: WorkoutPlan
    
    private var exerciseCount: Int {
        plan.exercises.count
    }
    
    private var exerciseText: String {
        exerciseCount == 1 ? "1 exercício" : "\(exerciseCount) exercícios"
    }
    
    var body: some View {
        NavigationLink(value: plan) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(plan.name)
                        .font(.headline)
                    
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
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Label(exerciseText, systemImage: "figure.strengthtraining.traditional")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(plan.createdDate.toRelativeString())
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    List {
        WorkoutPlanRowView(plan: WorkoutPlan(name: "Treino A", description: "Peito e Tríceps"))
        
        WorkoutPlanRowView(plan: {
            let plan = WorkoutPlan(name: "Treino B", description: "Costas e Bíceps com descrição muito longa que vai ocupar mais de uma linha")
            plan.isActive = true
            return plan
        }())
        
        WorkoutPlanRowView(plan: WorkoutPlan(name: "Treino C", description: ""))
    }
}
