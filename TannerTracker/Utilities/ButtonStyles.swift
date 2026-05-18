//
//  ButtonStyles.swift
//  TannerTracker
//

import SwiftUI

// For non-List rows (ProgressTabView, ExerciseEntryCard) where the button
// label already fills the full row — ButtonStyle background covers it correctly.
struct ListRowButtonStyle: ButtonStyle {
    var highlighted: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed && highlighted ? Color.white.opacity(0.08) : Color.clear)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// For native List rows — uses listRowBackground so the highlight covers the
// full cell height (including UIKit's minimum row height), not just the label frame.
private struct PressHighlightListRow: ViewModifier {
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .listRowBackground(
                Color(hex: "#242424")
                    .overlay(isPressed ? Color.white.opacity(0.08) : Color.clear)
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: .infinity)
                    .updating($isPressed) { value, state, _ in state = value }
            )
    }
}

extension View {
    func listRowPressHighlight() -> some View {
        modifier(PressHighlightListRow())
    }
}
