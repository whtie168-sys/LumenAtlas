//
//  AppState.swift
//  FocusToolkit
//
//  Global, lightweight UI state shared across the app (not persisted).
//

import SwiftUI
import Combine

/// App-wide ephemeral state: focus mode flag, selected tab, and the
/// "current task" surfaced inside Focus Mode.
final class AppState: ObservableObject {
    @AppStorage("focusModeEnabled") var focusModeEnabled: Bool = false

    @Published var selectedTab: AppTab = .timer

    /// Title of the task the user is currently focusing on (shown in Focus Mode).
    @AppStorage("currentFocusTaskTitle") var currentFocusTaskTitle: String = ""

    // Timer configuration (persisted, customizable per spec).
    @AppStorage("focusMinutes") var focusMinutes: Int = 25
    @AppStorage("breakMinutes") var breakMinutes: Int = 5

    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @AppStorage("dailyReminderEnabled") var dailyReminderEnabled: Bool = false

    // MARK: Current journey (Home dashboard goal)

    @AppStorage("journeyName") var journeyName: String = "Launch My First App"
    @AppStorage("journeyTotalDays") var journeyTotalDays: Int = 30
    /// Journey start, stored as a unix timestamp. Seeded on first launch.
    @AppStorage("journeyStartTimestamp") private var journeyStartTimestamp: Double = 0

    init() {
        // Seed the journey start date once so progress begins on day one.
        if journeyStartTimestamp == 0 {
            journeyStartTimestamp = Date().timeIntervalSince1970
        }
    }

    var journey: Journey {
        let start = journeyStartTimestamp > 0
            ? Date(timeIntervalSince1970: journeyStartTimestamp)
            : Date()
        return Journey(name: journeyName, startDate: start, totalDays: journeyTotalDays)
    }
}

enum AppTab: Int, CaseIterable, Identifiable {
    case timer, tasks, notes, stats, settings
    var id: Int { rawValue }

    var title: String {
        switch self {
        case .timer: return "Focus"
        case .tasks: return "Tasks"
        case .notes: return "Notes"
        case .stats: return "Stats"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .timer: return "timer"
        case .tasks: return "checkmark.circle"
        case .notes: return "note.text"
        case .stats: return "chart.bar.xaxis"
        case .settings: return "gearshape"
        }
    }
}
