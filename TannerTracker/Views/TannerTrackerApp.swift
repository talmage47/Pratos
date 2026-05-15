//
//  TannerTrackerApp.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

@main
struct TannerTrackerApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([Exercise.self, WorkoutEntry.self])
        container = Self.makeContainer(schema: schema)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .environment(AppSettings.shared)
                .preferredColorScheme(.dark)
        }
    }

    private static func makeContainer(schema: Schema) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, cloudKitDatabase: .automatic)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            // Schema changed and the existing store is incompatible — wipe and start fresh.
            // This only happens during development after model changes.
            // TODO: Replace with a proper SchemaMigrationPlan before App Store release.
            wipeDefaultStore()
            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }

    private static func wipeDefaultStore() {
        let base = URL.applicationSupportDirectory
        for name in ["default.store", "default.store-shm", "default.store-wal"] {
            try? FileManager.default.removeItem(at: base.appending(path: name))
        }
    }
}
