//
//  ExerciseRowView.swift
//  BumbumNaNuca
//
//  Componente de linha para exibir exercício
//

import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Ícone do grupo muscular
            Image(systemName: exercise.muscleGroup.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Color(exercise.muscleGroup.tagColor), in: Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                
                HStack(spacing: 12) {
                    Label("\(exercise.defaultSets)×\(exercise.defaultReps)", systemImage: "repeat")
                    
                    Text(exercise.muscleGroup.rawValue)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        ExerciseRowView(exercise: Exercise(
            name: "Supino Reto",
            muscleGroup: .chest,
            defaultSets: 4,
            defaultReps: 10
        ))
        
        ExerciseRowView(exercise: Exercise(
            name: "Remada Curvada",
            muscleGroup: .back,
            defaultSets: 3,
            defaultReps: 12
        ))
        
        ExerciseRowView(exercise: Exercise(
            name: "Agachamento",
            muscleGroup: .legs,
            defaultSets: 4,
            defaultReps: 15
        ))
    }
}
