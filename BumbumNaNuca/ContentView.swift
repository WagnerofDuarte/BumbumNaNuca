//
//  ContentView.swift
//  BumbumNaNuca
//
//  Created by Wagner Duarte on 20/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        WorkoutPlanListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
