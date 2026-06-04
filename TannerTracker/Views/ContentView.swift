//
//  ContentView.swift
//  TannerTracker
//

import SwiftUI

enum AppTab {
    case today, progress, add
}

struct ContentView: View {
    @Environment(AppSettings.self) var settings
    @State private var selectedTab: AppTab = .today
    @State private var showAddWorkout = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Workout", systemImage: "figure.strengthtraining.traditional", value: AppTab.today) {
                HomeView()
            }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis", value: AppTab.progress) {
                ProgressTabView()
            }
            Tab("Add", systemImage: "plus", value: AppTab.add, role: .search) {
                Color.clear
            }
        }
        .tint(settings.accentColor)
        .tabBarMinimizeBehavior(.onScrollDown)
        .onChange(of: selectedTab) { old, new in
            if new == .add {
                selectedTab = old
                showAddWorkout = true
            }
        }
        .sheet(isPresented: $showAddWorkout) {
            AddEntryView()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppSettings.shared)
}
