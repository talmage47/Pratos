//
//  SettingsView.swift
//  TannerTracker
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) var settings

    @State private var accentColor: Color = AppSettings.shared.accentColor

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                List {
                    // Units
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Unit System")
                                .font(.subheadline)
                                .foregroundStyle(.gray)

                            Picker("Unit System", selection: $settings.unitSystem) {
                                Text("Imperial (lbs)").tag("imperial")
                                Text("Metric (kg)").tag("metric")
                            }
                            .pickerStyle(.segmented)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color(hex: "#242424"))
                    } header: {
                        Text("Units")
                            .foregroundStyle(.gray)
                    }

                    // Accent Color
                    Section {
                        HStack {
                            Text("Accent Color")
                                .foregroundStyle(.white)
                            Spacer()
                            ColorPicker("", selection: $accentColor, supportsOpacity: false)
                                .labelsHidden()
                                .onChange(of: accentColor) { _, newColor in
                                    settings.accentColor = newColor
                                }
                        }
                        .listRowBackground(Color(hex: "#242424"))

                        HStack {
                            Text("Preview")
                                .foregroundStyle(.gray)
                            Spacer()
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(settings.accentColor)
                                    .frame(width: 22, height: 22)

                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(settings.accentColor, lineWidth: 1.5)
                                    .frame(width: 60, height: 22)
                            }
                        }
                        .listRowBackground(Color(hex: "#242424"))
                    } header: {
                        Text("Appearance")
                            .foregroundStyle(.gray)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(settings.accentColor)
                }
            }
            .onAppear {
                accentColor = settings.accentColor
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppSettings.shared)
}
