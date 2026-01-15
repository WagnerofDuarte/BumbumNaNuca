//
//  SetInputFields.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 10/01/26.
//

import SwiftUI

struct SetInputFields: View {
    @Binding var loadText: String
    @Binding var repsText: String
    let loadError: String?
    let repsError: String?
    let onLoadChange: () -> Void
    let onRepsChange: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                // Load input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Carga (kg)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("Peso corporal", text: $loadText)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.decimalPad)
                        .onChange(of: loadText) { _, _ in onLoadChange() }
                    
                    if let error = loadError {
                        Text(error)
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                
                // Reps input
                VStack(alignment: .leading, spacing: 4) {
                    Text("Repetições")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    TextField("Reps", text: $repsText)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .onChange(of: repsText) { _, _ in onRepsChange() }
                    
                    if let error = repsError {
                        Text(error)
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    VStack {
        SetInputFields(
            loadText: .constant("60.0"),
            repsText: .constant("12"),
            loadError: nil,
            repsError: nil,
            onLoadChange: {},
            onRepsChange: {}
        )
        .padding()
        
        SetInputFields(
            loadText: .constant(""),
            repsText: .constant(""),
            loadError: "Carga deve ser maior que 0",
            repsError: "Repetições obrigatórias",
            onLoadChange: {},
            onRepsChange: {}
        )
        .padding()
    }
}
