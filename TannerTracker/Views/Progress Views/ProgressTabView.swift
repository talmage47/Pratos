//
//  ProgressTabView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

struct ProgressTabView: View {
    @Environment(AppSettings.self) var settings
    @Query(filter: #Predicate<Exercise> { $0.isRemoved == false }, sort: \Exercise.name)
    private var exercises: [Exercise]

    @State private var showSettings = false
    @State private var searchText = ""

    private var filteredExercises: [Exercise] {
        guard !searchText.isEmpty else { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Progress")
                            .font(.largeTitle.bold())
                            .foregroundStyle(settings.accentColor)
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                            .padding(.bottom, 16)

                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.gray)
                            TextField("Search exercises", text: $searchText)
                                .foregroundStyle(.white)
                                .tint(settings.accentColor)
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.gray)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(Color(hex: "#2C2C2E"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                        if filteredExercises.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "figure.strengthtraining.traditional")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.gray.opacity(0.3))
                                Text(searchText.isEmpty ? "No exercises yet" : "No results")
                                    .foregroundStyle(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            LazyVStack(spacing: 0) {
                                ForEach(Array(filteredExercises.enumerated()), id: \.element.id) { index, exercise in
                                    NavigationLink(destination: ExerciseProgressView(exercise: exercise)) {
                                        HStack {
                                            Text(exercise.name)
                                                .foregroundStyle(.white)
                                                .fontWeight(.medium)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(.gray)
                                                .font(.caption.weight(.semibold))
                                        }
                                        .contentShape(Rectangle())
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 16)
                                    }
                                    .buttonStyle(ListRowButtonStyle())

                                    if index < filteredExercises.count - 1 {
                                        Rectangle()
                                            .fill(Color.white.opacity(0.08))
                                            .frame(height: 1)
                                            .padding(.leading, 20)
                                    }
                                }
                            }
                            .background(Color(hex: "#242424"))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.bottom, 100)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .navigationBarTitleDisplayMode(.inline)
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
    ProgressTabView()
        .environment(AppSettings.shared)
}
