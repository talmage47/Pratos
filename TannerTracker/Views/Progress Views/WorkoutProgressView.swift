//
//  WorkoutProgressView.swift
//  TannerTracker
//

import SwiftUI

struct WorkoutProgressView: View {
    @Environment(AppSettings.self) var settings

    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.gray.opacity(0.25))
                    Text("Progress")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Coming soon")
                        .foregroundStyle(.gray)
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(settings.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

#Preview {
    WorkoutProgressView()
        .environment(AppSettings.shared)
}
