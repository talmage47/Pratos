//
//  RemovedExercisesView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

struct RemovedExercisesView: View {
    @Environment(AppSettings.self) var settings

    @Query(filter: #Predicate<Exercise> { $0.isRemoved == true }, sort: \Exercise.name)
    private var removedExercises: [Exercise]

    @State private var editingExercise: Exercise? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                if removedExercises.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "trash.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.gray.opacity(0.3))
                        Text("No removed exercises")
                            .foregroundStyle(.gray)
                    }
                } else {
                    List {
                        ForEach(removedExercises) { exercise in
                            HStack {
                                Text(exercise.name)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onLongPressGesture(minimumDuration: 0.5) {
                                editingExercise = exercise
                            }
                            .listRowBackground(Color(hex: "#242424"))
                            .listRowSeparatorTint(Color.white.opacity(0.08))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }

                if let exercise = editingExercise {
                    actionOverlay(for: exercise)
                }
            }
            .navigationTitle("Removed Exercises")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDragIndicator(.visible)
    }

    private func actionOverlay(for exercise: Exercise) -> some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { editingExercise = nil }

            VStack(spacing: 14) {
                Text(exercise.name)
                    .font(.title3.bold())
                    .foregroundStyle(.white)
                    .padding(.bottom, 4)

                Button {
                    exercise.isRemoved = false
                    editingExercise = nil
                } label: {
                    Text("Recover Exercise")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    editingExercise = nil
                } label: {
                    Text("Delete Exercise")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    editingExercise = nil
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(24)
            .glassEffect(in: RoundedRectangle(cornerRadius: 22))
            .padding(.horizontal, 28)
        }
    }
}
