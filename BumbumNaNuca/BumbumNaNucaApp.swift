//
//  BumbumNaNucaApp.swift
//  BumbumNaNuca
//
//  Created by Wagner Duarte on 20/12/25.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct BumbumNaNucaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WorkoutPlan.self,
            Exercise.self,
            WorkoutSession.self,
            ExerciseSet.self,
            CheckIn.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Request UserNotifications permission for timer alerts
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Failed to request notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
