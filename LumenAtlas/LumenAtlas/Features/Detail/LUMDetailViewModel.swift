//
//  LUMDetailViewModel.swift
//  LumenAtlas
//
//  Backs the event detail screen: exposes the event, its per-axis breakdown and
//  a contextual note ("this was your highest focus this week"), plus delete.
//

import Foundation

final class LUMDetailViewModel {

    private let eventService: LUMEventServing
    private let analytics: LUMAnalyticsService
    private(set) var event: LUMEvent

    init(event: LUMEvent, eventService: LUMEventServing, analytics: LUMAnalyticsService) {
        self.event = event
        self.eventService = eventService
        self.analytics = analytics
    }

    var title: String { event.title }
    var composite: Int { event.compositeScore }
    var note: String { event.note }
    var tags: [String] { event.tags }

    var dateText: String { Self.formatter.string(from: event.timestamp) }

    var axisBreakdown: [(axis: LUMSignalAxis, value: Int)] {
        LUMSignalAxis.allCases.map { ($0, event.value(for: $0)) }
    }

    /// A short, data-derived observation comparing this event to the last 30 days.
    var contextualInsight: String {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let recent = eventService.events.filter { $0.timestamp >= cutoff }
        guard recent.count > 1 else { return "Your first signals — keep logging to unlock comparisons." }

        var notes: [String] = []
        for axis in LUMSignalAxis.allCases {
            let values = recent.map { $0.value(for: axis) }
            guard let maxV = values.max(), let minV = values.min() else { continue }
            let v = event.value(for: axis)
            if v == maxV && maxV != minV {
                notes.append("highest \(axis.title.lowercased()) in 30 days")
            } else if v == minV && maxV != minV {
                notes.append("lowest \(axis.title.lowercased()) in 30 days")
            }
        }
        return notes.isEmpty
            ? "A fairly typical reading across all signals."
            : "This was your " + notes.joined(separator: ", ") + "."
    }

    func delete() {
        eventService.delete(id: event.id)
    }

    /// Re-fetch in case it was edited while this screen was open.
    func refresh() {
        if let latest = eventService.event(with: event.id) {
            event = latest
        }
    }

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d · HH:mm"
        return f
    }()
}
