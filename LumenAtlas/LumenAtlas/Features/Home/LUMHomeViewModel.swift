//
//  LUMHomeViewModel.swift
//  LumenAtlas
//
//  Prepares everything the dashboard renders: the headline composite score, the
//  four current axis readings, a short rolling-average sparkline, recent events
//  and the most recent anomalies. All derived from the event store and refreshed
//  whenever it changes.
//

import Foundation

final class LUMHomeViewModel {

    struct AxisSummary {
        let axis: LUMSignalAxis
        let current: Int
        let trend: LUMTrendSeries.Direction
    }

    private let eventService: LUMEventServing
    private let analytics: LUMAnalyticsService
    private var token: LUMSubscriptionToken?

    /// Fired after a recompute so the VC can reload.
    var onChange: (() -> Void)?

    // Derived outputs the VC reads directly.
    private(set) var composite: Int = 0
    private(set) var axisSummaries: [AxisSummary] = []
    private(set) var emotionTrend: LUMTrendSeries = LUMTrendSeries(axis: .emotion, points: [])
    private(set) var recentEvents: [LUMEvent] = []
    private(set) var anomalies: [LUMAnomaly] = []
    private(set) var streakDays: Int = 0

    init(eventService: LUMEventServing, analytics: LUMAnalyticsService) {
        self.eventService = eventService
        self.analytics = analytics
        token = eventService.changes.subscribe { [weak self] in self?.recompute() }
        recompute()
    }

    var hasData: Bool { !eventService.events.isEmpty }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default:      return "Late night"
        }
    }

    func recompute() {
        let events = eventService.events

        // Headline = composite of the most recent event, or rolling mean if none today.
        composite = events.first?.compositeScore ?? 0

        axisSummaries = LUMSignalAxis.allCases.map { axis in
            let series = analytics.rollingAverage(for: axis, window: 7, events: events)
            let current = events.first?.value(for: axis) ?? Int(series.points.last?.value ?? 0)
            return AxisSummary(axis: axis, current: current, trend: series.direction)
        }

        emotionTrend = analytics.rollingAverage(for: .emotion, window: 7, events: events)
        recentEvents = Array(events.prefix(5))
        anomalies = Array(analytics.detectAnomalies(events: events).prefix(3))
        streakDays = computeStreak(events: events)

        onChange?()
    }

    /// Consecutive days (ending today or yesterday) that have at least one event.
    private func computeStreak(events: [LUMEvent]) -> Int {
        let calendar = Calendar.current
        let days = Set(events.map { calendar.startOfDay(for: $0.timestamp) })
        guard !days.isEmpty else { return 0 }

        var streak = 0
        var cursor = calendar.startOfDay(for: Date())
        // Allow the streak to count from yesterday if nothing logged yet today.
        if !days.contains(cursor) {
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        while days.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor)!
        }
        return streak
    }
}
