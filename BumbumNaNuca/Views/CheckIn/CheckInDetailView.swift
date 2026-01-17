//
//  CheckInDetailView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 16/01/26.
//  Feature 005: Check-In Detail Screen
//

import SwiftUI
import SwiftData

/// Exibe detalhes completos de um check-in incluindo foto e treino associado
struct CheckInDetailView: View {
    let checkIn: CheckIn
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Foto do Check-In
                if let image = checkIn.fullSizeImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else if let thumbnail = checkIn.thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                } else {
                    // Ícone placeholder em tamanho maior
                    PlaceholderIconView(exerciseType: checkIn.exerciseType, size: 200)
                        .padding()
                }
                
                // Informações do Check-In
                VStack(alignment: .leading, spacing: 16) {
                    // Título
                    VStack(alignment: .leading, spacing: 4) {
                        Text(checkIn.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(checkIn.formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Tipo de Exercício
                    infoRow(
                        icon: "figure.run",
                        label: "Tipo",
                        value: checkIn.exerciseType
                    )
                    
                    // Calorias (se disponível)
                    if let calories = checkIn.calories {
                        infoRow(
                            icon: "flame.fill",
                            label: "Calorias",
                            value: "\(calories) kcal"
                        )
                    }
                    
                    // Localização (se disponível)
                    if let location = checkIn.location, !location.isEmpty {
                        infoRow(
                            icon: "location.fill",
                            label: "Local",
                            value: location
                        )
                    }
                    
                    // Observações (se disponível)
                    if !checkIn.notes.isEmpty {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Observações", systemImage: "note.text")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(checkIn.notes)
                                .font(.body)
                        }
                    }
                    
                    // Treino Associado (se disponível)
                    if let workoutSession = checkIn.workoutSession {
                        Divider()
                        
                        workoutSessionSection(workoutSession)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Detalhes do Check-In")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper Views
    
    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .fontWeight(.medium)
            
            Spacer()
        }
    }
    
    private func workoutSessionSection(_ session: WorkoutSession) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Treino Realizado", systemImage: "dumbbell.fill")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                // Nome do Plano de Treino
                if let plan = session.workoutPlan {
                    HStack {
                        Text("Plano:")
                            .foregroundColor(.secondary)
                        Text(plan.name)
                            .fontWeight(.medium)
                    }
                }
                
                // Duração
                HStack {
                    Text("Duração:")
                        .foregroundColor(.secondary)
                    Text(session.formattedDuration)
                        .fontWeight(.medium)
                }
                
                // Exercícios Completados
                HStack {
                    Text("Exercícios:")
                        .foregroundColor(.secondary)
                    Text("\(session.completedExercisesCount) completados")
                        .fontWeight(.medium)
                }
                
                // Botão para ver detalhes do treino
                NavigationLink {
                    WorkoutSessionDetailView(session: session)
                } label: {
                    HStack {
                        Text("Ver Detalhes do Treino")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .foregroundColor(.accentColor)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
    }
}

// MARK: - Preview

#Preview("With Photo and Workout") {
    NavigationStack {
        CheckInDetailView(
            checkIn: CheckIn(
                date: Date(),
                notes: "Great workout session!",
                photoData: nil,
                exerciseType: "Gym",
                title: "Morning Workout",
                calories: 350,
                location: "Home Gym"
            )
        )
    }
    .modelContainer(for: CheckIn.self, inMemory: true)
}

#Preview("Without Photo") {
    NavigationStack {
        CheckInDetailView(
            checkIn: CheckIn(
                date: Date(),
                notes: "",
                photoData: nil,
                exerciseType: "Run",
                title: "Evening Run"
            )
        )
    }
    .modelContainer(for: CheckIn.self, inMemory: true)
}
