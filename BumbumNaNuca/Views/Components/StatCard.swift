//
//  StatCard.swift
//  BumbumNaNuca
//
//  Created by AI Assistant on 09/01/26.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    
    init(title: String, value: String, subtitle: String? = nil, icon: String, iconColor: Color = .blue) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)" + (subtitle != nil ? ", \(subtitle!)" : ""))
    }
}

#Preview {
    VStack(spacing: 16) {
        StatCard(
            title: "Sequência Atual",
            value: "5 dias",
            subtitle: "Continue assim!",
            icon: "flame.fill",
            iconColor: .orange
        )
        
        StatCard(
            title: "Check-ins do Mês",
            value: "18/31",
            subtitle: "58%",
            icon: "calendar",
            iconColor: .green
        )
    }
    .padding()
}
