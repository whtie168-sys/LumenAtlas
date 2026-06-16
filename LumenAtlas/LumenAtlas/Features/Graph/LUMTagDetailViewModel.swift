//
//  LUMTagDetailViewModel.swift
//  LumenAtlas
//
//  Tag drill-down reached from a graph node: the tag's events, its related tags
//  (graph neighbours ranked by edge strength) and its average mood.
//

import Foundation

final class LUMTagDetailViewModel {

    struct RelatedTag {
        let tag: String
        let strength: Double
        let coOccurrence: Int
    }

    let tag: String
    private let eventService: LUMEventServing
    private let graphService: LUMGraphService
    private let analytics: LUMAnalyticsService

    init(tag: String,
         eventService: LUMEventServing,
         graphService: LUMGraphService,
         analytics: LUMAnalyticsService) {
        self.tag = tag
        self.eventService = eventService
        self.graphService = graphService
        self.analytics = analytics
    }

    var events: [LUMEvent] {
        eventService.events.filter { $0.tags.contains(tag) }
    }

    var averageMood: Int {
        let scores = events.map { $0.compositeScore }
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    /// Related tags from the graph, strongest first.
    var relatedTags: [RelatedTag] {
        let graph = graphService.buildGraph(from: eventService.events)
        return graph.edges
            .filter { $0.source == tag || $0.target == tag }
            .map { edge in
                let other = edge.source == tag ? edge.target : edge.source
                return RelatedTag(tag: other, strength: edge.strength, coOccurrence: edge.coOccurrence)
            }
            .sorted { $0.strength > $1.strength }
    }
}
