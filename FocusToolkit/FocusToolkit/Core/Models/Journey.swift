//
//  Journey.swift
//  FocusToolkit
//
//  A lightweight "current journey" goal shown on the Home dashboard.
//  Purely a visual progress target — no new navigation or module.
//

import Foundation

struct Journey {
    var name: String
    var startDate: Date
    var totalDays: Int

    /// Whole days elapsed since the start (clamped to [1, totalDays]).
    var daysCompleted: Int {
        let start = DateUtils.startOfDay(startDate)
        let today = DateUtils.startOfDay(Date())
        let elapsed = (DateUtils.calendar.dateComponents([.day], from: start, to: today).day ?? 0) + 1
        return min(max(1, elapsed), totalDays)
    }

    var daysRemaining: Int {
        max(0, totalDays - daysCompleted)
    }

    /// 0...1 progress through the journey.
    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return min(1, Double(daysCompleted) / Double(totalDays))
    }

    var progressPercent: Int {
        Int((progress * 100).rounded())
    }
}
