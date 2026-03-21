//
//  AppSettings.swift
//  TannerTracker
//

import SwiftUI

@Observable
class AppSettings {
    static let shared = AppSettings()

    var unitSystem: String {
        didSet { UserDefaults.standard.set(unitSystem, forKey: "unitSystem") }
    }

    var accentColorHex: String {
        didSet { UserDefaults.standard.set(accentColorHex, forKey: "accentColorHex") }
    }

    var accentColor: Color {
        get { Color(hex: accentColorHex) }
        set { accentColorHex = newValue.toHex() }
    }

    var unitLabel: String {
        unitSystem == "imperial" ? "lbs" : "kg"
    }

    private init() {
        self.unitSystem = UserDefaults.standard.string(forKey: "unitSystem") ?? "imperial"
        self.accentColorHex = UserDefaults.standard.string(forKey: "accentColorHex") ?? "#FF6B35"
    }
}
