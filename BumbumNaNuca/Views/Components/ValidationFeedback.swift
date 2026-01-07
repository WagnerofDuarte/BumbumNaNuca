//
//  ValidationFeedback.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 07/01/26.
//

import SwiftUI

struct ValidationFeedback: View {
    let message: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.caption)
            
            Text(message)
                .font(.caption)
        }
        .foregroundColor(.red)
    }
}

#Preview {
    ValidationFeedback(message: "Repetições devem ser maior que zero")
}
