//
//  CheckInView.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 15/01/26.
//  Feature 005: Register Check-In Flow - Replaces Feature 003 version
//

import SwiftUI
import SwiftData

/// Tab de Check-In - entrada principal para Feature 005
struct CheckInView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        CheckInTabView(modelContext: modelContext)
    }
}

#Preview {
    CheckInView()
        .modelContainer(for: CheckIn.self, inMemory: true)
}
