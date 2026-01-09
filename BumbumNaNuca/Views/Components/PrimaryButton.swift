//
//  PrimaryButton.swift
//  BumbumNaNuca
//
//  Componente reutilizável para botões primários do app
//

import SwiftUI
import OSLog

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
    }
}

#Preview {
    VStack(spacing: 16) {
        PrimaryButton(title: "Salvar") {
            AppLogger.ui.debug("Preview: Salvar tapped")
        }
        
        PrimaryButton(title: "Excluir", isDestructive: true) {
            AppLogger.ui.debug("Preview: Excluir tapped")
        }
    }
    .padding()
}
