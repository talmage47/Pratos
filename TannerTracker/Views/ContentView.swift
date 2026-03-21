//
//  ContentView.swift
//  TannerTracker
//

import SwiftUI

enum AppTab {
    case today, photos, progress, threshold
}

struct ContentView: View {
    @Environment(AppSettings.self) var settings
    @State private var selectedTab: AppTab = .today
    @State private var showAddWorkout = false

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            Group {
                switch selectedTab {
                case .today:
                    TodayView()
                case .photos:
                    PhotosView()
                case .progress:
                    WorkoutProgressView()
                case .threshold:
                    ThresholdView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(
                selectedTab: $selectedTab,
                showAddWorkout: $showAddWorkout,
                accentColor: settings.accentColor
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showAddWorkout) {
            AddWorkoutView()
        }
        .tint(settings.accentColor)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Binding var showAddWorkout: Bool
    var accentColor: Color

    var body: some View {
        HStack(spacing: 0) {
            TabBarItem(icon: "calendar", label: "Today", isSelected: selectedTab == .today, accentColor: accentColor) {
                selectedTab = .today
            }

            TabBarItem(icon: "camera", label: "Photos", isSelected: selectedTab == .photos, accentColor: accentColor) {
                selectedTab = .photos
            }

            // Pronounced center add button
            Button {
                showAddWorkout = true
            } label: {
                ZStack {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 60, height: 60)
                        .shadow(color: accentColor.opacity(0.55), radius: 14, y: 4)

                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .offset(y: -12)

            TabBarItem(icon: "dumbbell", label: "Progress", isSelected: selectedTab == .progress, accentColor: accentColor) {
                selectedTab = .progress
            }

            TabBarItem(icon: "figure.strengthtraining.traditional", label: "Lifts", isSelected: selectedTab == .threshold, accentColor: accentColor) {
                selectedTab = .threshold
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 0.5)
        }
    }
}

struct TabBarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? accentColor : Color.gray)
                Text(label)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? accentColor : Color.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
        .environment(AppSettings.shared)
}
