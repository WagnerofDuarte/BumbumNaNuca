//
//  CheckInView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftUI
import SwiftData

struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = CheckInViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Botão principal de check-in
                checkInButton
                
                // Streaks
                HStack(spacing: 16) {
                    StreakBadge(streak: viewModel.currentStreak)
                    
                    if viewModel.longestStreak > 0 {
                        StreakBadge(streak: viewModel.longestStreak, isLongest: true)
                    }
                }
                .padding(.horizontal)
                
                // Estatísticas mensais
                StatCard(
                    title: "Check-ins do Mês",
                    value: "\(viewModel.monthlyStats.totalCheckIns)/\(viewModel.monthlyStats.totalDaysInMonth)",
                    subtitle: viewModel.monthlyStats.formattedPercentage,
                    icon: "calendar",
                    iconColor: .green
                )
                .padding(.horizontal)
                
                // Título da lista
                if !viewModel.recentCheckIns.isEmpty {
                    Text("Últimos Check-ins")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                }
                
                // Lista de check-ins recentes
                if viewModel.recentCheckIns.isEmpty {
                    emptyState
                } else {
                    checkInsList
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Check-in")
        .onAppear {
            viewModel.loadCheckInData(context: modelContext)
        }
        .refreshable {
            viewModel.loadCheckInData(context: modelContext)
        }
    }
    
    // MARK: - Check-in Button
    
    private var checkInButton: some View {
        Button(action: {
            let success = viewModel.performCheckIn(context: modelContext)
            if success {
                // Optional: Add haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }) {
            HStack {
                Image(systemName: viewModel.canCheckInToday ? "calendar.badge.plus" : "checkmark.circle.fill")
                    .font(.title3)
                
                Text(viewModel.checkInButtonText)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(viewModel.canCheckInToday ? Color.blue : Color.green)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .disabled(!viewModel.canCheckInToday)
        .padding(.horizontal)
    }
    
    // MARK: - Check-ins List
    
    private var checkInsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(viewModel.recentCheckIns) { checkIn in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(checkIn.date.toRelativeString())
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(checkIn.date.toTimeString())
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if !checkIn.notes.isEmpty {
                        Text(checkIn.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("Nenhum check-in ainda")
                .font(.headline)
            
            Text("Faça seu primeiro check-in para começar sua sequência!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        CheckInView()
    }
    .modelContainer(for: CheckIn.self, inMemory: true)
}
