//
//  ContentView.swift
//  BumbumNaNuca
//
//  Created by Wagner Duarte on 20/12/25.
//  Modified by AI Assistant on 09/01/26 - Added TabView navigation
//

import SwiftUI
import SwiftData

// MARK: - Tab Enum

enum Tab: String, CaseIterable {
    case home = "Home"
    case workouts = "Treinos"
    case progress = "Progresso"
    case checkin = "Check-in"
    
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .workouts: return "dumbbell.fill"
        case .progress: return "chart.bar.fill"
        case .checkin: return "calendar.badge.checkmark"
        }
    }
}

// MARK: - Navigation Environment

struct NavigateToWorkoutAction {
    let action: (WorkoutPlan) -> Void
    func callAsFunction(_ workout: WorkoutPlan) { action(workout) }
}

private struct NavigateToWorkoutKey: EnvironmentKey {
    static let defaultValue = NavigateToWorkoutAction { _ in }
}

struct NavigateToHomeAction {
    let action: () -> Void
    func callAsFunction() { action() }
}

private struct NavigateToHomeKey: EnvironmentKey {
    static let defaultValue = NavigateToHomeAction { }
}

extension EnvironmentValues {
    var navigateToWorkout: NavigateToWorkoutAction {
        get { self[NavigateToWorkoutKey.self] }
        set { self[NavigateToWorkoutKey.self] = newValue }
    }
    
    var navigateToHome: NavigateToHomeAction {
        get { self[NavigateToHomeKey.self] }
        set { self[NavigateToHomeKey.self] = newValue }
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var selectedTab: Tab = .home
    
    // Independent navigation paths per tab
    @State private var homeNavPath = NavigationPath()
    @State private var workoutsNavPath = NavigationPath()
    @State private var progressNavPath = NavigationPath()
    @State private var checkinNavPath = NavigationPath()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $homeNavPath) {
                HomeView()
            }
            .tabItem {
                Label(Tab.home.rawValue, systemImage: Tab.home.icon)
            }
            .tag(Tab.home)
            
            NavigationStack(path: $workoutsNavPath) {
                WorkoutPlanListView()
            }
            .tabItem {
                Label(Tab.workouts.rawValue, systemImage: Tab.workouts.icon)
            }
            .tag(Tab.workouts)
            
            NavigationStack(path: $progressNavPath) {
                ProgressView()
            }
            .tabItem {
                Label(Tab.progress.rawValue, systemImage: Tab.progress.icon)
            }
            .tag(Tab.progress)
            
            NavigationStack(path: $checkinNavPath) {
                CheckInView()
            }
            .tabItem {
                Label(Tab.checkin.rawValue, systemImage: Tab.checkin.icon)
            }
            .tag(Tab.checkin)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Pop to root when re-tapping same tab
            if oldValue == newValue {
                popToRoot(for: newValue)
            }
        }
        .environment(\.navigateToWorkout, NavigateToWorkoutAction { workout in
            // Cross-tab navigation: Home → Workouts tab → Plan detail
            selectedTab = .workouts
            workoutsNavPath.append(workout)
        })
        .environment(\.navigateToHome, NavigateToHomeAction {
            // Clear all navigation stacks and return to home
            popToRoot(for: .home)
            popToRoot(for: .workouts)
            selectedTab = .home
        })
    }
    
    private func popToRoot(for tab: Tab) {
        switch tab {
        case .home: homeNavPath = NavigationPath()
        case .workouts: workoutsNavPath = NavigationPath()
        case .progress: progressNavPath = NavigationPath()
        case .checkin: checkinNavPath = NavigationPath()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: WorkoutPlan.self, inMemory: true)
}
