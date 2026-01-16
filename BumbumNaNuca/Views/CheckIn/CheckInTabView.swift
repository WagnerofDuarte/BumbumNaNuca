//
//  CheckInTabView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 3
//

import SwiftUI
import SwiftData

/// Tab de Check-In com resumo e calendário mensal
struct CheckInTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CheckInViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: CheckInViewModel())
    }
    
    var body: some View {
        NavigationStack {
            if viewModel.totalCheckIns == 0 && !viewModel.isLoading {
                // Estado vazio
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Seção de Resumo
                        summarySection
                        
                        // Calendário do Mês Atual
                        currentMonthSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Check-Ins")
        .onAppear {
            viewModel.loadCheckInData(context: modelContext)
        }
        .refreshable {
            viewModel.loadCheckInData(context: modelContext)
        }
    }
    
    // MARK: - Summary Section
    
    private var summarySection: some View {
        VStack(spacing: 16) {
            // Total de Check-ins
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total de Check-Ins")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.totalCheckIns)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            
            // Estatísticas adicionais (sequência, etc)
            HStack(spacing: 12) {
                // Sequência Atual
                statCard(
                    title: "Sequência",
                    value: "\(viewModel.currentStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                // Melhor Sequência
                statCard(
                    title: "Recorde",
                    value: "\(viewModel.longestStreak)",
                    icon: "star.fill",
                    color: .yellow
                )
            }
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Current Month Section
    
    private var currentMonthSection: some View {
        VStack(spacing: 16) {
            // Cabeçalho
            HStack {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            // Calendário
            CalendarMonthView(
                month: viewModel.currentMonth,
                checkIns: viewModel.currentMonthCheckIns
            )
            
            // Botão "Ver Todos os Check-Ins"
            NavigationLink {
                AllCheckInsView(modelContext: modelContext)
            } label: {
                HStack {
                    Image(systemName: "calendar")
                    Text("Ver Todos os Check-Ins")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.secondarySystemBackground))
                .foregroundColor(.accentColor)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Computed Properties
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        let formatted = formatter.string(from: viewModel.currentMonth)
        return formatted.prefix(1).capitalized + formatted.dropFirst()
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Nenhum Check-In Ainda")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Comece sua jornada registrando seu primeiro check-in com foto!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CheckInTabView(modelContext: ModelContext(
        try! ModelContainer(for: CheckIn.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    ))
}
