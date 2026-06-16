//
//  LUMInsightViewModel.swift
//  LumenAtlas
//
//  The "insight engine": synthesises higher-level observations by combining the
//  analytics primitives — correlating stress spikes with tags, surfacing the
//  best/worst recurring contexts, and reporting the strongest tag relationship.
//  These are derived statements, not stored content.
//

import Foundation

final class LUMInsightViewModel {

    struct Insight {
        enum Tone { case positive, caution, neutral }
        let icon: String
        let headline: String
        let detail: String
        let tone: Tone
    }

    private let eventService: LUMEventServing
    private let analytics: LUMAnalyticsService
    private let graphService: LUMGraphService

    init(eventService: LUMEventServing,
         analytics: LUMAnalyticsService,
         graphService: LUMGraphService) {
        self.eventService = eventService
        self.analytics = analytics
        self.graphService = graphService
    }

    func generate() -> [Insight] {
        let events = eventService.events
        guard events.count >= 3 else {
            return [Insight(icon: "sparkles",
                            headline: "Keep logging",
                            detail: "Add a few more signals to unlock pattern insights.",
                            tone: .neutral)]
        }

        var insights: [Insight] = []
        insights.append(contentsOf: stressTagInsight(events))
        insights.append(contentsOf: bestContextInsight(events))
        insights.append(contentsOf: trendInsight(events))
        insights.append(contentsOf: relationshipInsight(events))
        return insights
    }

    /// Which tag co-occurs most with high-stress events?
    private func stressTagInsight(_ events: [LUMEvent]) -> [Insight] {
        let stressful = events.filter { $0.stress >= 70 }
        guard stressful.count >= 2 else { return [] }
        var counts: [String: Int] = [:]
        for event in stressful {
            for tag in event.tags { counts[tag, default: 0] += 1 }
        }
        guard let top = counts.max(by: { $0.value < $1.value }), top.value >= 2 else { return [] }
        return [Insight(icon: "exclamationmark.triangle.fill",
                        headline: "“\(top.key)” tracks with stress",
                        detail: "\(top.value) of your high-stress moments are tagged “\(top.key)”. Worth a closer look.",
                        tone: .caution)]
    }

    /// The tag with the highest average composite score.
    private func bestContextInsight(_ events: [LUMEvent]) -> [Insight] {
        let ranks = analytics.rankTags(events: events).filter { $0.count >= 2 }
        guard let best = ranks.max(by: { $0.averageComposite < $1.averageComposite }) else { return [] }
        return [Insight(icon: "leaf.fill",
                        headline: "“\(best.tag)” lifts you",
                        detail: "Events tagged “\(best.tag)” average a composite of \(Int(best.averageComposite)) — your most positive recurring context.",
                        tone: .positive)]
    }

    /// Direction of the 7-day emotion trend.
    private func trendInsight(_ events: [LUMEvent]) -> [Insight] {
        let series = analytics.rollingAverage(for: .emotion, window: 7, events: events)
        switch series.direction {
        case .rising:
            return [Insight(icon: "arrow.up.right.circle.fill",
                            headline: "Emotion trending up",
                            detail: "Your 7-day emotion average has been climbing. Whatever you're doing, it's working.",
                            tone: .positive)]
        case .falling:
            return [Insight(icon: "arrow.down.right.circle.fill",
                            headline: "Emotion dipping",
                            detail: "Your 7-day emotion average is sliding. Consider what's changed recently.",
                            tone: .caution)]
        case .flat:
            return [Insight(icon: "equal.circle.fill",
                            headline: "Steady emotional baseline",
                            detail: "Your emotional signal has been stable over the past week.",
                            tone: .neutral)]
        }
    }

    /// The strongest tag relationship in the graph.
    private func relationshipInsight(_ events: [LUMEvent]) -> [Insight] {
        let graph = graphService.buildGraph(from: events)
        guard let edge = graph.edges.first else { return [] }
        return [Insight(icon: "link.circle.fill",
                        headline: "“\(edge.source)” + “\(edge.target)”",
                        detail: "Your strongest tag pairing — appearing together \(edge.coOccurrence) times.",
                        tone: .neutral)]
    }
}
