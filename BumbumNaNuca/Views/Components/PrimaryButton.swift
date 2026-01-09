//
//  PrimaryButton.swift
//  BumbumNaNuca
//
//  Componente reutilizável para botões primários do app
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(isDestructive ? .red : .accentColor)
        .accessibilityLabel(title)
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Salvar") {
            print("Salvar")
        }
        
        PrimaryButton(title: "Excluir", isDestructive: true) {
            print("Excluir")
        }
    }
    .padding()
}
