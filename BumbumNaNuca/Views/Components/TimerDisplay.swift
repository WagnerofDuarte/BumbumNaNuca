//
//  TimerDisplay.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 10/01/26.
//

import SwiftUI

/// Displays countdown timer with circular progress
struct TimerDisplay: View {
    let viewModel: RestTimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Tempo de Descanso")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        Color.accentColor,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: viewModel.progress)
                
                // Time text
                VStack(spacing: 8) {
                    Text(viewModel.timeString)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    if viewModel.isRunning {
                        Text("restantes")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // Status message
            if !viewModel.isRunning && viewModel.remainingTime <= 0 {
                Text("Descanso concluído!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}

#Preview("TimerDisplay - Running") {
    TimerDisplay(
        viewModel: {
            let vm = RestTimerViewModel(duration: 60)
            vm.start()
            return vm
        }()
    )
}

#Preview("TimerDisplay - Completed") {
    TimerDisplay(
        viewModel: {
            let vm = RestTimerViewModel(duration: 0)
            return vm
        }()
    )
}
