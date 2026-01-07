//
//  EmptyStateView.swift
//  BumbumNaNuca
//
//  Wrapper para ContentUnavailableView mostrando estados vazios
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
        } description: {
            Text(message)
        } actions: {
            if let actionTitle, let action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    EmptyStateView(
        icon: "list.bullet.clipboard",
        title: "Nenhum Plano",
        message: "Crie seu primeiro plano de treino para começar",
        actionTitle: "Criar Plano"
    ) {
        print("Criar plano")
    }
}
