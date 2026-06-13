//
//  StatsViewModel.swift
//  FocusToolkit
//
//  Aggregates completed FocusSessions into daily totals, streak, and counts.
//

import Foundation
import CoreData
import Combine

struct DayStat: Identifiable {
    let id = UUID()
    let date: Date
    let minutes: Int
    let sessions: Int

    var weekday: String { DateUtils.shortWeekday(date) }
}

@MainActor
final class StatsViewModel: ObservableObject {
    @Published private(set) var week: [DayStat] = []
    @Published private(set) var todayMinutes: Int = 0
    @Published private(set) var totalSessions: Int = 0
    @Published private(set) var streak: Int = 0
    @Published private(set) var bestDayMinutes: Int = 0
    @Published private(set) var achievements: [Achievement] = []

    func reload(context: NSManagedObjectContext, journeyCompleted: Bool = false) {
        let sessions = (try? context.fetch(FocusSession.completedRequest())) ?? []

        // Build last-7-day buckets.
        let days = DateUtils.lastSevenDays()
        week = days.map { day in
            let daySessions = sessions.filter { DateUtils.isSameDay($0.startDate, day) }
            let minutes = daySessions.reduce(0) { $0 + $1.focusedMinutes }
            return DayStat(date: day, minutes: minutes, sessions: daySessions.count)
        }

        todayMinutes = week.last?.minutes ?? 0
        totalSessions = sessions.count
        streak = TimerViewModel.computeStreak(from: sessions)
        bestDayMinutes = week.map(\.minutes).max() ?? 0

        let stats = FocusStats.load(context: context)
        achievements = AchievementCatalog.all(stats: stats, journeyCompleted: journeyCompleted)
    }
}
