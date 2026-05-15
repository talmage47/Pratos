//
//  ExerciseProgressView.swift
//  TannerTracker
//

import SwiftUI
import SwiftData
import Charts

struct ExerciseProgressView: View {
    let exercise: Exercise
    @Environment(AppSettings.self) var settings
    @Query private var allEntries: [WorkoutEntry]

    private var exerciseEntries: [WorkoutEntry] {
        allEntries.filter { $0.exercise?.persistentModelID == exercise.persistentModelID }
    }

    private func epleyValue(weight: Double, reps: Int) -> Double {
        weight * (1 + Double(reps) / 30.0)
    }

    private struct DayEpley: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }

    private var epleyData: [DayEpley] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: exerciseEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        return grouped.map { day, entries in
            let maxEpley = entries.map { epleyValue(weight: $0.weight, reps: $0.reps) }.max() ?? 0
            return DayEpley(date: day, value: maxEpley)
        }
        .sorted { $0.date < $1.date }
    }

    private var xDomain: ClosedRange<Date> {
        guard epleyData.count > 1,
              let first = epleyData.first?.date,
              let last = epleyData.last?.date else {
            let d = epleyData.first?.date ?? Date()
            return d...d
        }
        return first...last
    }

    private var epleyYDomain: ClosedRange<Double> {
        guard let min = epleyData.map(\.value).min(),
              let max = epleyData.map(\.value).max(),
              max > min else {
            return 0...100
        }
        let padding = (max - min) * 0.15
        return (min - padding)...(max + padding)
    }

    // Dates to show as x-axis tick marks: always first & last, at most 6 total.
    private var xAxisValues: [Date] {
        guard !epleyData.isEmpty else { return [] }
        let dates = epleyData.map(\.date)
        guard dates.count > 1 else { return dates }

        let maxLabels = 6
        guard dates.count > maxLabels else { return dates }

        var result = [dates.first!]
        let innerCount = maxLabels - 2
        for i in 1...innerCount {
            let idx = Int(Double(i) * Double(dates.count - 1) / Double(innerCount + 1))
            result.append(dates[idx])
        }
        result.append(dates.last!)
        return result
    }

    // Pre-built label strings keyed by date. First date (or first in a new year) gets the year appended.
    private var xAxisLabelStrings: [Date: String] {
        let values = xAxisValues
        let calendar = Calendar.current
        var dict = [Date: String]()

        for (i, date) in values.enumerated() {
            let year = calendar.component(.year, from: date)
            let showYear = i == 0 || calendar.component(.year, from: values[i - 1]) != year

            dict[date] = showYear
                ? date.formatted(.dateTime.month(.abbreviated).day().year(.defaultDigits))
                : date.formatted(.dateTime.month(.abbreviated).day())
        }
        return dict
    }

    var body: some View {
        ZStack {
            Color(hex: "#1A1A1A").ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    epleyCard
                    maxWeightByRepsCard
                }
                .padding(16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private var epleyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Epley Formula")
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("(weight × (1 + reps/30))")
                    .font(.caption)
                    .italic()
                    .foregroundStyle(.gray)
            }

            if epleyData.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 36))
                        .foregroundStyle(.gray.opacity(0.3))
                    Text("No data yet")
                        .foregroundStyle(.gray)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 200)
            } else {
                Chart(epleyData) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Est. 1RM", point.value)
                    )
                    .foregroundStyle(settings.accentColor)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("Est. 1RM", point.value)
                    )
                    .foregroundStyle(settings.accentColor)
                    .symbolSize(30)
                }
                .frame(height: 230)
                .chartXScale(domain: xDomain)
                .chartYScale(domain: epleyYDomain)
                .chartXAxis {
                    AxisMarks(values: xAxisValues) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel {
                            if let date = value.as(Date.self),
                               let label = xAxisLabelStrings[date] {
                                Text(label)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .fixedSize()
                                    .rotationEffect(.degrees(-90))
                                    .frame(height: 50)
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.white.opacity(0.08))
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("\(Int(v)) \(settings.unitLabel)")
                                    .foregroundStyle(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(hex: "#242424"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var maxWeightByRepsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Max Weight By Reps")
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                Image(systemName: "chart.bar.xaxis")
                    .font(.system(size: 36))
                    .foregroundStyle(.gray.opacity(0.3))
                Text("Coming soon")
                    .foregroundStyle(.gray)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
        }
        .padding(16)
        .background(Color(hex: "#242424"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
