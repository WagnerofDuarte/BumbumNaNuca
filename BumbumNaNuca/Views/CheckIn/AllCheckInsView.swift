//
//  AllCheckInsView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - User Story 4
//

import SwiftUI
import SwiftData

/// Visualização de todos os check-ins históricos agrupados por mês
struct AllCheckInsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewModel: CalendarViewModel
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: CalendarViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 32) {
                ForEach(viewModel.monthsWithCheckIns, id: \.month) { monthData in
                    VStack(spacing: 16) {
                        // Cabeçalho do mês
                        HStack {
                            Text(monthYearString(for: monthData.month))
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(monthData.checkIns.count) check-in\(monthData.checkIns.count != 1 ? "s" : "")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Calendário do mês
                        CalendarMonthView(
                            month: monthData.month,
                            checkIns: monthData.checkIns
                        )
                    }
                    .padding(.horizontal)
                }
                
                if viewModel.monthsWithCheckIns.isEmpty && !viewModel.isLoading {
                    emptyState
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Todos os Check-Ins")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadAllMonths()
        }
        .refreshable {
            viewModel.loadAllMonths()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("Nenhum Check-In Registrado")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Seus check-ins aparecerão aqui quando você começar a registrá-los")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    // MARK: - Helpers
    
    private func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        let formatted = formatter.string(from: date)
        return formatted.prefix(1).capitalized + formatted.dropFirst()
    }
}

#Preview {
    NavigationStack {
        AllCheckInsView(modelContext: ModelContext(
            try! ModelContainer(for: CheckIn.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        ))
    }
}
