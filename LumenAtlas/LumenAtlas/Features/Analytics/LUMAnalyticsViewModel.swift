//
//  LUMAnalyticsViewModel.swift
//  LumenAtlas
//
//  Drives the analytics tab: per-axis rolling-average series, the focus
//  distribution histogram, tag rankings and time clusters. A selectable window
//  (7/14/30 days) reshapes the source set before the engine runs.
//

import Foundation

final class LUMAnalyticsViewModel {

    enum Window: Int, CaseIterable {
        case week = 7, fortnight = 14, month = 30
        var title: String {
            switch self {
            case .week: return "7D"
            case .fortnight: return "14D"
            case .month: return "30D"
            }
        }
    }

    private let eventService: LUMEventServing
    private let analytics: LUMAnalyticsService
    private var token: LUMSubscriptionToken?

    var onChange: (() -> Void)?
    var window: Window = .fortnight { didSet { recompute() } }

    private(set) var trends: [LUMTrendSeries] = []
    private(set) var focusDistribution: LUMDistribution?
    private(set) var tagRanks: [LUMTagRank] = []
    private(set) var clusters: [LUMCluster] = []

    init(eventService: LUMEventServing, analytics: LUMAnalyticsService) {
        self.eventService = eventService
        self.analytics = analytics
        token = eventService.changes.subscribe { [weak self] in self?.recompute() }
        recompute()
    }

    var isEmpty: Bool { eventService.events.isEmpty }

    /// Events within the selected window, measured back from now.
    private func windowedEvents() -> [LUMEvent] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -window.rawValue, to: Date())!
        return eventService.events.filter { $0.timestamp >= cutoff }
    }

    func recompute() {
        let events = windowedEvents()
        trends = LUMSignalAxis.allCases.map {
            analytics.rollingAverage(for: $0, window: 7, events: events)
        }
        focusDistribution = analytics.distribution(for: .focus, events: events)
        tagRanks = Array(analytics.rankTags(events: events).prefix(8))
        clusters = Array(analytics.clusterByTime(events: events).prefix(5))
        onChange?()
    }
}
