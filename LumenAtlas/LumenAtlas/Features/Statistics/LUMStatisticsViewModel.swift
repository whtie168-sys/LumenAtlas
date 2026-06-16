//
//  LUMStatisticsViewModel.swift
//  LumenAtlas
//
//  Aggregate lifetime statistics: totals, per-axis means/extremes, most active
//  day-of-week and a logging-consistency figure. Read-only summary of the store.
//

import Foundation

final class LUMStatisticsViewModel {

    struct AxisStat {
        let axis: LUMSignalAxis
        let mean: Int
        let min: Int
        let max: Int
    }

    private let eventService: LUMEventServing
    private let analytics: LUMAnalyticsService

    init(eventService: LUMEventServing, analytics: LUMAnalyticsService) {
        self.eventService = eventService
        self.analytics = analytics
    }

    private var events: [LUMEvent] { eventService.events }

    var totalEvents: Int { events.count }
    var totalTags: Int { Set(events.flatMap(\.tags)).count }

    var daysCovered: Int {
        let calendar = Calendar.current
        return Set(events.map { calendar.startOfDay(for: $0.timestamp) }).count
    }

    var axisStats: [AxisStat] {
        LUMSignalAxis.allCases.compactMap { axis in
            let values = events.map { $0.value(for: axis) }
            guard let minV = values.min(), let maxV = values.max(), !values.isEmpty else { return nil }
            let mean = values.reduce(0, +) / values.count
            return AxisStat(axis: axis, mean: mean, min: minV, max: maxV)
        }
    }

    /// The weekday with the most logged events.
    var mostActiveDay: String? {
        guard !events.isEmpty else { return nil }
        let calendar = Calendar.current
        var counts: [Int: Int] = [:]
        for event in events {
            let weekday = calendar.component(.weekday, from: event.timestamp)
            counts[weekday, default: 0] += 1
        }
        guard let top = counts.max(by: { $0.value < $1.value }) else { return nil }
        return calendar.weekdaySymbols[top.key - 1]
    }

    /// Logging consistency: days with an entry divided by the full calendar span.
    var consistency: Int {
        guard let earliest = events.map(\.timestamp).min() else { return 0 }
        let calendar = Calendar.current
        let span = max(1, calendar.dateComponents([.day],
                                                  from: calendar.startOfDay(for: earliest),
                                                  to: calendar.startOfDay(for: Date())).day! + 1)
        return Int(Double(daysCovered) / Double(span) * 100)
    }

    var totalClusters: Int {
        analytics.clusterByTime(events: events).count
    }
}
