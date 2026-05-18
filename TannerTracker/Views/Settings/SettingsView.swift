//
//  SettingsView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppSettings.self) var settings

    @State private var accentColor: Color = AppSettings.shared.accentColor
    @State private var showWorkoutList = false
    @State private var showRemovedExercises = false
    @State private var dummySelectedExercise: Exercise? = nil


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

                    // Exercises
                    Section {
                        Button {
                            showWorkoutList = true
                        } label: {
                            HStack {
                                Text("Workout List")
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.gray)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowPressHighlight()

                        Button {
                            showRemovedExercises = true
                        } label: {
                            HStack {
                                Text("Removed Exercises")
                                    .foregroundStyle(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.gray)
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowPressHighlight()
                    } header: {
                        Text("Exercises")
                            .foregroundStyle(.gray)
                    }

                    #if DEBUG
                    Section {
                        Button {
                            loadSampleData()
                        } label: {
                            HStack {
                                Text("Load Sample Data")
                                    .foregroundStyle(.orange)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowPressHighlight()

                        Button {
                            wipeAllData()
                        } label: {
                            HStack {
                                Text("Wipe All Data")
                                    .foregroundStyle(.red)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .listRowPressHighlight()
                    } header: {
                        Text("Developer")
                            .foregroundStyle(.gray)
                    }
                    #endif
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
        .sheet(isPresented: $showWorkoutList) {
            ExerciseSelectorView(selectedExercise: $dummySelectedExercise)
        }
        .sheet(isPresented: $showRemovedExercises) {
            RemovedExercisesView()
        }
    }

    #if DEBUG
    private func loadSampleData() {
        let existing = (try? modelContext.fetch(FetchDescriptor<Exercise>())) ?? []
        let existingNames = Set(existing.map { $0.name })

        let calendar = Calendar.current
        let today = Date()

        typealias EntryTuple = (weight: Double, reps: Int, sets: Int, daysAgo: Int)
        let exerciseData: [(name: String, history: [EntryTuple], todayWeight: Double, todayReps: Int, todaySets: Int)] = [
            ("Bench Press",
             [(95,10,3,42),(105,10,3,35),(115,8,3,28),(125,8,3,21),(135,6,3,14),(140,6,4,7)],
             145, 5, 4),
            ("Squat",
             [(135,10,3,40),(145,10,3,33),(155,8,3,26),(165,8,3,19),(175,6,3,12),(185,6,4,5)],
             195, 5, 4),
            ("Deadlift",
             [(185,8,3,38),(205,8,3,31),(225,6,3,24),(245,5,3,17),(265,5,3,10),(275,4,3,3)],
             285, 3, 3),
            ("Overhead Press",
             [(65,10,3,36),(70,10,3,29),(75,8,3,22),(80,8,3,15),(85,6,3,8),(90,6,3,1)],
             95, 5, 3),
            ("Barbell Row",
             [(95,10,3,34),(105,10,3,27),(115,8,3,20),(125,8,3,13),(135,6,3,6)],
             140, 6, 3),
            ("Pull-ups",
             [(0,8,3,30),(0,10,3,23),(0,12,3,16),(0,12,4,9),(0,12,4,2)],
             0, 12, 4)
        ]

        for data in exerciseData {
            guard !existingNames.contains(data.name) else { continue }
            let exercise = Exercise(name: data.name)
            modelContext.insert(exercise)
            for entry in data.history {
                let date = calendar.date(byAdding: .day, value: -entry.daysAgo, to: today) ?? today
                modelContext.insert(WorkoutEntry(
                    exercise: exercise,
                    weight: entry.weight,
                    reps: entry.reps,
                    sets: entry.sets,
                    date: date
                ))
            }
            modelContext.insert(WorkoutEntry(
                exercise: exercise,
                weight: data.todayWeight,
                reps: data.todayReps,
                sets: data.todaySets,
                date: today
            ))
        }
    }

    private func wipeAllData() {
        try? modelContext.delete(model: WorkoutEntry.self)
        try? modelContext.delete(model: Exercise.self)
    }
    #endif
}


#Preview {
    SettingsView()
        .environment(AppSettings.shared)
}
