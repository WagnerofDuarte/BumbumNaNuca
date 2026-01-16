//
//  WorkoutSummaryView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI

struct WorkoutSummaryView: View {
    let session: WorkoutSession
    let onFinish: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: WorkoutSummaryViewModel?
    
    var body: some View {
        Group {
            if viewModel != nil {
                summaryContent
            } else {
                ProgressView()
                    .onAppear {
                        self.viewModel = WorkoutSummaryViewModel(session: session)
                    }
            }
        }
        .navigationBarBackButtonHidden()
    }
    
    @ViewBuilder
    private var summaryContent: some View {
        if let viewModel = viewModel {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Treino Concluído!")
                        .font(.largeTitle.bold())
                }
                .padding(.top, 40)
                
                // Summary cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    SummaryCard(
                        title: "Duração",
                        value: viewModel.formattedDuration,
                        icon: "clock.fill"
                    )
                    
                    SummaryCard(
                        title: "Exercícios",
                        value: "\(viewModel.completedExercisesCount)",
                        icon: "figure.strengthtraining.traditional"
                    )
                    
                    SummaryCard(
                        title: "Séries",
                        value: "\(viewModel.totalSets)",
                        icon: "square.stack.3d.up.fill"
                    )
                    
                    SummaryCard(
                        title: "Repetições",
                        value: "\(viewModel.totalReps)",
                        icon: "number"
                    )
                }
                .padding()
                
                Spacer()
                
                // Action button
                Button(action: { 
                    dismiss()
                    onFinish()
                }) {
                    Text("Finalizar")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.title.bold())
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    let session = WorkoutSession(startDate: Date().addingTimeInterval(-3600))
    session.endDate = Date()
    session.isCompleted = true
    
    // Simular alguns sets
    let set1 = ExerciseSet(setNumber: 1, weight: 80, reps: 10)
    let set2 = ExerciseSet(setNumber: 2, weight: 80, reps: 8)
    let set3 = ExerciseSet(setNumber: 3, weight: 70, reps: 12)
    
    session.exerciseSets = [set1, set2, set3]
    
    return NavigationStack {
        WorkoutSummaryView(session: session, onFinish: {
            print("Preview: Workout finished")
        })
    }
}
