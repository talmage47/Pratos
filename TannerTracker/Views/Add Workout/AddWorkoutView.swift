//
//  AddWorkoutView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

struct AddWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) var settings
    @Query(sort: \Exercise.name) private var exercises: [Exercise]

    var editingEntry: WorkoutEntry?

    @State private var selectedExerciseName: String
    @State private var weight: Int
    @State private var reps: Int
    @State private var sets: Int
    @State private var showExerciseSelector = false

    init(editingEntry: WorkoutEntry? = nil) {
        self.editingEntry = editingEntry
        _selectedExerciseName = State(initialValue: editingEntry?.exerciseName ?? "")
        _weight = State(initialValue: editingEntry?.weight ?? 0)
        _reps = State(initialValue: editingEntry?.reps ?? 10)
        _sets = State(initialValue: editingEntry?.sets ?? 3)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        exerciseSelector
                        weightPicker
                        repsSetsPicker
                        saveButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationTitle(editingEntry == nil ? "Add Workout" : "Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
            }
        }
        .sheet(isPresented: $showExerciseSelector) {
            ExerciseSelectorView(exercises: exercises, selectedName: $selectedExerciseName)
        }
    }

    // MARK: - Exercise Selector

    private var exerciseSelector: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Exercise")

            Button {
                showExerciseSelector = true
            } label: {
                HStack {
                    Text(selectedExerciseName.isEmpty ? "Select Exercise" : selectedExerciseName)
                        .foregroundStyle(selectedExerciseName.isEmpty ? Color.gray : Color.white)
                        .font(.body)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(hex: "#242424"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(settings.accentColor.opacity(0.4), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Weight Picker

    private var weightPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Weight (\(settings.unitLabel))")

            HStack(spacing: 0) {
                Spacer()

                Picker("Weight", selection: $weight) {
                    ForEach(0...999, id: \.self) { val in
                        Text("\(val)").tag(val)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 120, height: 160)

                Text(settings.unitLabel)
                    .font(.body)
                    .foregroundStyle(.gray)
                    .frame(width: 44, alignment: .leading)

                Spacer()
            }
            .background(Color(hex: "#242424"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(settings.accentColor.opacity(0.4), lineWidth: 1)
            )
        }
    }

    // MARK: - Reps & Sets Pickers

    private var repsSetsPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionLabel(text: "Reps & Sets")

            HStack(spacing: 0) {
                // Reps column
                HStack(spacing: 8) {
                    Text("Reps:")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                        .frame(minWidth: 44, alignment: .trailing)

                    Picker("Reps", selection: $reps) {
                        ForEach(1...50, id: \.self) { val in
                            Text("\(val)").tag(val)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 72, height: 130)
                }
                .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 1)
                    .padding(.vertical, 16)

                // Sets column
                HStack(spacing: 8) {
                    Text("Sets:")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                        .frame(minWidth: 44, alignment: .trailing)

                    Picker("Sets", selection: $sets) {
                        ForEach(1...20, id: \.self) { val in
                            Text("\(val)").tag(val)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 72, height: 130)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(hex: "#242424"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(settings.accentColor.opacity(0.4), lineWidth: 1)
            )
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Text(editingEntry == nil ? "Save Workout" : "Update Workout")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedExerciseName.isEmpty ? Color.gray.opacity(0.3) : settings.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(selectedExerciseName.isEmpty)
    }

    private func save() {
        if let entry = editingEntry {
            entry.exerciseName = selectedExerciseName
            entry.weight = weight
            entry.reps = reps
            entry.sets = sets
        } else {
            let entry = WorkoutEntry(
                exerciseName: selectedExerciseName,
                weight: weight,
                reps: reps,
                sets: sets
            )
            modelContext.insert(entry)
        }
        dismiss()
    }
}

// MARK: - Section Label

struct SectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.gray)
            .textCase(.uppercase)
            .tracking(0.5)
    }
}

// MARK: - Exercise Selector Sheet

struct ExerciseSelectorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) var settings

    let exercises: [Exercise]
    @Binding var selectedName: String

    @State private var showNewExercisePopup = false
    @State private var newExerciseName = ""
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                List {
                    ForEach(exercises) { exercise in
                        Button {
                            selectedName = exercise.name
                            dismiss()
                        } label: {
                            HStack {
                                Text(exercise.name)
                                    .foregroundStyle(.white)
                                Spacer()
                                if selectedName == exercise.name {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(settings.accentColor)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .listRowBackground(Color(hex: "#242424"))
                        .listRowSeparatorTint(Color.white.opacity(0.08))
                    }

                    Button {
                        showNewExercisePopup = true
                        nameFieldFocused = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(settings.accentColor)
                            Text("Create New Exercise")
                                .foregroundStyle(settings.accentColor)
                        }
                    }
                    .listRowBackground(Color(hex: "#242424"))
                    .listRowSeparatorTint(Color.white.opacity(0.08))
                }
                .scrollContentBackground(.hidden)

                // Liquid glass new exercise popup
                if showNewExercisePopup {
                    newExerciseOverlay
                }
            }
            .navigationTitle("Select Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
            }
        }
    }

    private var newExerciseOverlay: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissPopup()
                }

            VStack(spacing: 20) {
                VStack(spacing: 6) {
                    Image(systemName: "dumbbell.fill")
                        .font(.title2)
                        .foregroundStyle(settings.accentColor)

                    Text("New Exercise")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                }

                TextField("Exercise name", text: $newExerciseName)
                    .textFieldStyle(.plain)
                    .focused($nameFieldFocused)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .submitLabel(.done)
                    .onSubmit {
                        if !newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty {
                            createExercise()
                        }
                    }

                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismissPopup()
                    }
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Create") {
                        createExercise()
                    }
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? Color.gray.opacity(0.3) : settings.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .disabled(newExerciseName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(24)
            .glassEffect(in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 28)
        }
    }

    private func dismissPopup() {
        nameFieldFocused = false
        showNewExercisePopup = false
        newExerciseName = ""
    }

    private func createExercise() {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let exercise = Exercise(name: trimmed)
        modelContext.insert(exercise)
        selectedName = trimmed
        dismissPopup()
        dismiss()
    }
}

#Preview {
    AddWorkoutView()
        .environment(AppSettings.shared)
}
