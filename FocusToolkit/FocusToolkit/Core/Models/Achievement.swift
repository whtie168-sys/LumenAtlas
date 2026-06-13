//
//  Achievement.swift
//  FocusToolkit
//
//  Lightweight, predefined achievements. No backend, no gamification engine —
//  just visual progress indicators derived from existing stats.
//

import SwiftUI

enum AchievementKind: String, CaseIterable, Identifiable {
    case firstSession
    case streak7
    case sessions30
    case hours100
    case journeyDone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstSession: return "First Focus"
        case .streak7: return "7 Day Streak"
        case .sessions30: return "30 Sessions"
        case .hours100: return "100 Hours"
        case .journeyDone: return "Journey Complete"
        }
    }

    var detail: String {
        switch self {
        case .firstSession: return "Complete your first focus session"
        case .streak7: return "Focus 7 days in a row"
        case .sessions30: return "Finish 30 focus sessions"
        case .hours100: return "Reach 100 hours of focus"
        case .journeyDone: return "Complete a journey"
        }
    }

    var icon: String {
        switch self {
        case .firstSession: return "bolt.fill"
        case .streak7: return "flame.fill"
        case .sessions30: return "checkmark.seal.fill"
        case .hours100: return "hourglass"
        case .journeyDone: return "flag.checkered"
        }
    }

    var tint: Color {
        switch self {
        case .firstSession: return Theme.accentBlue
        case .streak7: return Theme.warning
        case .sessions30: return Theme.accent
        case .hours100: return Theme.accentAlt
        case .journeyDone: return Color(hex: "#A855F7") // purple
        }
    }

    /// Goal value for the progress bar.
    var target: Int {
        switch self {
        case .firstSession: return 1
        case .streak7: return 7
        case .sessions30: return 30
        case .hours100: return 100
        case .journeyDone: return 1
        }
    }
}

struct Achievement: Identifiable {
    let kind: AchievementKind
    /// Current progress value toward `kind.target`.
    let current: Int

    var id: String { kind.id }
    var isUnlocked: Bool { current >= kind.target }

    /// 0...1 fraction toward unlock.
    var progress: Double {
        guard kind.target > 0 else { return 0 }
        return min(1, Double(current) / Double(kind.target))
    }

    /// Short progress label, e.g. "5/7" or "Unlocked".
    var progressLabel: String {
        isUnlocked ? "Unlocked" : "\(current)/\(kind.target)"
    }
}

enum AchievementCatalog {
    /// Build the full ordered list from current stats.
    static func all(stats: FocusStats, journeyCompleted: Bool) -> [Achievement] {
        AchievementKind.allCases.map { kind in
            let current: Int
            switch kind {
            case .firstSession: current = min(1, stats.totalSessions)
            case .streak7: current = stats.currentStreak
            case .sessions30: current = stats.totalSessions
            case .hours100: current = stats.totalHours
            case .journeyDone: current = journeyCompleted ? 1 : 0
            }
            return Achievement(kind: kind, current: current)
        }
    }

    /// Unlocked first, then closest-to-unlock — used for the "recent" row on Home.
    static func recent(stats: FocusStats, journeyCompleted: Bool, limit: Int = 3) -> [Achievement] {
        let sorted = all(stats: stats, journeyCompleted: journeyCompleted).sorted { a, b in
            if a.isUnlocked != b.isUnlocked { return a.isUnlocked && !b.isUnlocked }
            return a.progress > b.progress
        }
        return Array(sorted.prefix(limit))
    }
}
