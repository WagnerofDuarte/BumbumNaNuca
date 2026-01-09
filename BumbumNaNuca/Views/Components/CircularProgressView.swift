//
//  CircularProgressView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI

struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    
    init(progress: Double, lineWidth: CGFloat = 8) {
        self.progress = progress
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.accentColor,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
        }
        .accessibilityLabel("Progresso")
        .accessibilityValue("\(Int(progress * 100)) por cento")
    }
}

#Preview {
    VStack(spacing: 30) {
        CircularProgressView(progress: 0.0)
            .frame(width: 100, height: 100)
        
        CircularProgressView(progress: 0.33)
            .frame(width: 100, height: 100)
        
        CircularProgressView(progress: 0.66)
            .frame(width: 100, height: 100)
        
        CircularProgressView(progress: 1.0)
            .frame(width: 100, height: 100)
    }
    .padding()
}
