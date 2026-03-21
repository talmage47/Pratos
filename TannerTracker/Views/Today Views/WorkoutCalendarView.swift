//
//  WorkoutCalendarView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData

struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct WorkoutCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) var settings
    @Query(sort: \WorkoutEntry.date) private var allEntries: [WorkoutEntry]

    @State private var currentMonth = Date()
    @State private var selectedDay: IdentifiableDate?

    private let calendar = Calendar.current
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 7)
    private let dayAbbreviations = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

    private var datesWithWorkouts: Set<String> {
        Set(allEntries.map { dayKey($0.date) })
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                VStack(spacing: 0) {
                    monthNavigationHeader

                    dayOfWeekRow

                    LazyVGrid(columns: gridColumns, spacing: 6) {
                        ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, date in
                            if let date {
                                CalendarDayCell(
                                    date: date,
                                    isToday: calendar.isDateInToday(date),
                                    hasWorkout: datesWithWorkouts.contains(dayKey(date)),
                                    accentColor: settings.accentColor
                                ) {
                                    if datesWithWorkouts.contains(dayKey(date)) {
                                        selectedDay = IdentifiableDate(date: date)
                                    }
                                }
                            } else {
                                Color.clear
                                    .aspectRatio(1, contentMode: .fit)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(settings.accentColor)
                }
            }
        }
        .sheet(item: $selectedDay) { identDate in
            DayWorkoutsView(date: identDate.date)
        }
    }

    private var monthNavigationHeader: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(settings.accentColor)
            }

            Spacer()

            Text(currentMonth, format: .dateTime.month(.wide).year())
                .font(.title3.bold())
                .foregroundStyle(.white)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(settings.accentColor)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private var dayOfWeekRow: some View {
        HStack {
            ForEach(dayAbbreviations, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    private var calendarDays: [Date?] {
        let startOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentMonth)
        )!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count

        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfMonth) {
                days.append(date)
            }
        }
        return days
    }

    private func dayKey(_ date: Date) -> String {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return "\(comps.year!)-\(comps.month!)-\(comps.day!)"
    }
}

struct CalendarDayCell: View {
    let date: Date
    let isToday: Bool
    let hasWorkout: Bool
    let accentColor: Color
    let action: () -> Void

    private let calendar = Calendar.current

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                ZStack {
                    if isToday {
                        Circle()
                            .stroke(accentColor, lineWidth: 1.5)
                            .frame(width: 34, height: 34)
                    }

                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 15, weight: isToday ? .bold : .regular))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                }

                Circle()
                    .fill(hasWorkout ? accentColor : Color.clear)
                    .frame(width: 5, height: 5)
            }
        }
        .buttonStyle(.plain)
        .disabled(!hasWorkout)
        .opacity(hasWorkout || isToday ? 1.0 : 0.4)
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Day Workouts Sheet

struct DayWorkoutsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(AppSettings.self) var settings
    @Query(sort: \WorkoutEntry.date) private var allEntries: [WorkoutEntry]

    let date: Date

    @State private var editingEntry: WorkoutEntry?

    private var dayEntries: [WorkoutEntry] {
        allEntries.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }

    private var dateTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1A1A1A").ignoresSafeArea()

                if dayEntries.isEmpty {
                    Text("No workouts on this day")
                        .foregroundStyle(.gray)
                } else {
                    List {
                        ForEach(dayEntries) { entry in
                            WorkoutEntryRow(
                                entry: entry,
                                unitLabel: settings.unitLabel,
                                accentColor: settings.accentColor
                            )
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            .onTapGesture {
                                editingEntry = entry
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    modelContext.delete(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle(dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(settings.accentColor)
                }
            }
        }
        .sheet(item: $editingEntry) { entry in
            AddWorkoutView(editingEntry: entry)
        }
    }
}

#Preview {
    WorkoutCalendarView()
        .environment(AppSettings.shared)
}
