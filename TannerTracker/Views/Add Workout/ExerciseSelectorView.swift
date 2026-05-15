//
//  ExerciseSelectorView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

struct ExerciseSelectorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) var settings

    @Query(filter: #Predicate<Exercise> { $0.isRemoved == false }, sort: \Exercise.name)
    private var exercises: [Exercise]

    @Binding var selectedExercise: Exercise?

    @State private var searchText = ""
    @State private var showNewExercisePopup = false
    @State private var newExerciseName = ""
    @FocusState private var nameFieldFocused: Bool

    @State private var editingExercise: Exercise? = nil
    @State private var editingName = ""
    @State private var showRemoveWarning = false
    @FocusState private var editFieldFocused: Bool

    private var filteredExercises: [Exercise] {
        guard !searchText.isEmpty else { return exercises }
        return exercises.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var hasExactMatch: Bool {
        exercises.contains { $0.name.localizedCaseInsensitiveCompare(searchText) == .orderedSame }
    }

    private var canSaveEdit: Bool {
        let trimmed = editingName.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && trimmed != editingExercise?.name
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                List {
                    ForEach(filteredExercises) { exercise in
                        HStack {
                            Text(exercise.name)
                                .foregroundStyle(.white)
                            Spacer()
                            if selectedExercise?.persistentModelID == exercise.persistentModelID {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(settings.accentColor)
                                    .fontWeight(.semibold)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExercise = exercise
                            dismiss()
                        }
                        .onLongPressGesture(minimumDuration: 0.5) {
                            editingExercise = exercise
                            editingName = exercise.name
                        }
                        .listRowBackground(Color(hex: "#242424"))
                        .listRowSeparatorTint(Color.white.opacity(0.08))
                    }

                    if !searchText.isEmpty && !hasExactMatch {
                        Button {
                            addExercise(name: searchText)
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(settings.accentColor)
                                Text("Add \"\(searchText)\"")
                                    .foregroundStyle(settings.accentColor)
                            }
                        }
                        .listRowBackground(Color(hex: "#242424"))
                        .listRowSeparatorTint(Color.white.opacity(0.08))
                    } else if searchText.isEmpty {
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
                }
                .scrollContentBackground(.hidden)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search exercises")

                if showNewExercisePopup {
                    newExerciseOverlay
                }

                if editingExercise != nil {
                    editExerciseOverlay
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
        .presentationDragIndicator(.visible)
        .onChange(of: editingExercise) { _, new in
            if new != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    editFieldFocused = true
                }
            }
        }
        .alert("Remove Exercise", isPresented: $showRemoveWarning) {
            Button("Remove", role: .destructive) {
                editingExercise?.isRemoved = true
                dismissEditPopup()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This exercise will be removed from the list but can be recovered in Settings.")
        }
    }

    // MARK: - New Exercise Overlay

    private var newExerciseOverlay: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { dismissNewPopup() }

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
                    Button("Cancel") { dismissNewPopup() }
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Create") { createExercise() }
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

    // MARK: - Edit Exercise Overlay

    private var editExerciseOverlay: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { dismissEditPopup() }

            VStack(spacing: 20) {
                Text("Edit Exercise")
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                TextField("Exercise name", text: $editingName)
                    .textFieldStyle(.plain)
                    .focused($editFieldFocused)
                    .padding(12)
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundStyle(.white)
                    .submitLabel(.done)
                    .onSubmit {
                        if canSaveEdit { saveEdit() }
                    }

                HStack(spacing: 12) {
                    Button("Cancel") { dismissEditPopup() }
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Save") { saveEdit() }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(canSaveEdit ? settings.accentColor : Color.gray.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .disabled(!canSaveEdit)
                }

                Button("Remove Exercise") {
                    showRemoveWarning = true
                }
                .foregroundStyle(.red)
                .font(.subheadline.weight(.medium))
            }
            .padding(24)
            .glassEffect(in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 28)
        }
    }

    // MARK: - Actions

    private func addExercise(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let exercise = Exercise(name: trimmed)
        modelContext.insert(exercise)
        selectedExercise = exercise
        dismiss()
    }

    private func dismissNewPopup() {
        nameFieldFocused = false
        showNewExercisePopup = false
        newExerciseName = ""
    }

    private func createExercise() {
        let trimmed = newExerciseName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let exercise = Exercise(name: trimmed)
        modelContext.insert(exercise)
        selectedExercise = exercise
        dismissNewPopup()
        dismiss()
    }

    private func saveEdit() {
        let trimmed = editingName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, let exercise = editingExercise else { return }
        exercise.name = trimmed
        dismissEditPopup()
    }

    private func dismissEditPopup() {
        editFieldFocused = false
        editingExercise = nil
        editingName = ""
        showRemoveWarning = false
    }
}
