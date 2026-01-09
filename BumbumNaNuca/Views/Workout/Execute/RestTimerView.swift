//
//  RestTimerView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI
import OSLog

struct RestTimerView: View {
    @State private var viewModel: RestTimerViewModel
    let duration: TimeInterval
    let onComplete: () -> Void
    
    init(duration: TimeInterval, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        self._viewModel = State(initialValue: RestTimerViewModel())
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Descanso")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            ZStack {
                CircularProgressView(progress: viewModel.progress, lineWidth: 12)
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 8) {
                    Text(viewModel.formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .monospacedDigit()
                    
                    Text("restantes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                if viewModel.isPaused {
                    Button {
                        viewModel.resume()
                    } label: {
                        Label("Retomar", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else if viewModel.isRunning {
                    Button {
                        viewModel.pause()
                    } label: {
                        Label("Pausar", systemImage: "pause.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                
                Button {
                    viewModel.skip()
                    onComplete()
                } label: {
                    Label("Pular", systemImage: "forward.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            viewModel.start(duration: duration)
        }
        .onChange(of: viewModel.isCompleted) { _, isCompleted in
            if isCompleted {
                onComplete()
            }
        }
    }
}

#Preview {
    RestTimerView(duration: 90) {
        AppLogger.execution.debug("Preview: Timer completed")
    }
}
