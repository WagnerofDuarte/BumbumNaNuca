//
//  SetInputView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI

struct SetInputView: View {
    @Binding var weightText: String
    @Binding var repsText: String
    let weightError: String?
    let repsError: String?
    let onWeightChange: () -> Void
    let onRepsChange: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Weight input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Peso (kg)", text: $weightText)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: weightText) { _, _ in onWeightChange() }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(weightError != nil ? Color.red : Color.clear, lineWidth: 2)
                        )
                        .accessibilityLabel("Peso em quilogramas")
                        .accessibilityHint("Deixe vazio para peso corporal")
                    
                    Text("kg")
                        .foregroundColor(.secondary)
                }
                
                if let error = weightError {
                    ValidationFeedback(message: error)
                }
                
                Text("Deixe vazio para peso corporal")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            // Reps input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    TextField("Repetições", text: $repsText)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: repsText) { _, _ in onRepsChange() }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(repsError != nil ? Color.red : Color.clear, lineWidth: 2)
                        )
                        .accessibilityLabel("Número de repetições")
                    
                    Text("reps")
                        .foregroundColor(.secondary)
                }
                
                if let error = repsError {
                    ValidationFeedback(message: error)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var weight = "80"
    @Previewable @State var reps = "10"
    
    SetInputView(
        weightText: $weight,
        repsText: $reps,
        weightError: nil,
        repsError: nil,
        onWeightChange: {},
        onRepsChange: {}
    )
    .padding()
}
