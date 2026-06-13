//
//  FocusStats.swift
//  FocusToolkit
//
//  Aggregates completed focus sessions + tasks into the numbers shown on the
//  Home dashboard (focus score, weekly change, totals, completed tasks).
//

import Foundation
import CoreData

struct FocusStats {
    var todayMinutes: Int = 0
    var currentStreak: Int = 0
    var completedTasks: Int = 0
    var totalSessions: Int = 0
    var totalMinutes: Int = 0

    /// Composite 0...100 "focus score" derived from this week's effort.
    var focusScore: Int = 0
    /// Percent change vs. the previous week (can be negative).
    var weeklyChangePercent: Int = 0

    var totalHours: Int { totalMinutes / 60 }

    static let empty = FocusStats()

    /// Build all dashboard stats from CoreData in one pass.
    static func load(context: NSManagedObjectContext) -> FocusStats {
        var stats = FocusStats()

        let sessions = (try? context.fetch(FocusSession.completedRequest())) ?? []
        stats.totalSessions = sessions.count
        stats.totalMinutes = sessions.reduce(0) { $0 + $1.focusedMinutes }
        stats.currentStreak = TimerViewModel.computeStreak(from: sessions)

        let today = Date()
        stats.todayMinutes = sessions
            .filter { DateUtils.isSameDay($0.startDate, today) }
            .reduce(0) { $0 + $1.focusedMinutes }

        // Completed tasks.
        let taskRequest = TaskItem.allRequest()
        let tasks = (try? context.fetch(taskRequest)) ?? []
        stats.completedTasks = tasks.filter { $0.isCompleted }.count

        // This week vs. last week minutes (for the weekly change %).
        let cal = DateUtils.calendar
        let startOfToday = DateUtils.startOfDay(today)
        let thisWeekStart = cal.date(byAdding: .day, value: -6, to: startOfToday) ?? startOfToday
        let lastWeekStart = cal.date(byAdding: .day, value: -13, to: startOfToday) ?? startOfToday

        let thisWeekMinutes = sessions
            .filter { $0.startDate >= thisWeekStart }
            .reduce(0) { $0 + $1.focusedMinutes }
        let lastWeekMinutes = sessions
            .filter { $0.startDate >= lastWeekStart && $0.startDate < thisWeekStart }
            .reduce(0) { $0 + $1.focusedMinutes }

        stats.focusScore = computeScore(weekMinutes: thisWeekMinutes, streak: stats.currentStreak)

        if lastWeekMinutes > 0 {
            let change = Double(thisWeekMinutes - lastWeekMinutes) / Double(lastWeekMinutes) * 100
            stats.weeklyChangePercent = Int(change.rounded())
        } else {
            stats.weeklyChangePercent = thisWeekMinutes > 0 ? 100 : 0
        }

        return stats
    }

    /// Score blends weekly focus minutes (target ~300/wk) with streak momentum.
    private static func computeScore(weekMinutes: Int, streak: Int) -> Int {
        let minuteComponent = min(1.0, Double(weekMinutes) / 300.0) * 80.0
        let streakComponent = min(1.0, Double(streak) / 7.0) * 20.0
        return min(100, Int((minuteComponent + streakComponent).rounded()))
    }
}
