//
//  ThresholdView.swift
//  TannerTracker
//

import SwiftUI

struct ThresholdView: View {
    @Environment(AppSettings.self) var settings

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                VStack(spacing: 16) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 64))
                        .foregroundStyle(Color.gray.opacity(0.25))
                    Text("Threshold")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Text("Coming soon")
                        .foregroundStyle(.gray)
                }
            }
            .navigationTitle("Threshold")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    ThresholdView()
        .environment(AppSettings.shared)
}
