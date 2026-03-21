//
//  TannerTrackerApp.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

@main
struct TannerTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Exercise.self, WorkoutEntry.self])
                .environment(AppSettings.shared)
                .preferredColorScheme(.dark)
        }
    }
}
