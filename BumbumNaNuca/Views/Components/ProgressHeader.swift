//
//  ProgressHeader.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI

struct ProgressHeader: View {
    let progress: Double  // 0.0 to 1.0
    let text: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(text)
                    .font(.headline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .foregroundColor(.accentColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: geometry.size.width * progress, height: 4)
                        .cornerRadius(2)
                }
            }
            .frame(height: 4)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressHeader(progress: 0.0, text: "0/8 exercícios completos")
        ProgressHeader(progress: 0.5, text: "4/8 exercícios completos")
        ProgressHeader(progress: 1.0, text: "8/8 exercícios completos")
    }
    .padding()
}
