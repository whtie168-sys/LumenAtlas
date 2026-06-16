//
//  LUMGraphService.swift
//  LumenAtlas
//
//  Builds the tag relationship graph. An edge forms whenever two tags appear on
//  the same event; its strength blends how often that happens with how tightly
//  clustered in time those shared events are. The result is the data behind the
//  Memory Graph screen.
//

import Foundation

final class LUMGraphService {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    /// Construct the full graph from the event set.
    ///
    /// Strength model: for each unordered tag pair we count co-occurrences and
    /// collect the timestamps of the shared events. Temporal proximity is the
    /// inverse of the mean inter-event spacing normalised against a 14-day
    /// reference window — pairs that recur close together score higher than
    /// pairs that co-occur once a month. The two factors are combined
    /// multiplicatively so an edge needs both volume *and* tightness to be strong.
    func buildGraph(from events: [LUMEvent]) -> LUMGraph {
        guard !events.isEmpty else { return .empty }

        var tagCounts: [String: Int] = [:]
        var tagComposite: [String: Int] = [:]
        var pairCount: [String: Int] = [:]
        var pairTimestamps: [String: [Date]] = [:]

        for event in events {
            for tag in event.tags {
                tagCounts[tag, default: 0] += 1
                tagComposite[tag, default: 0] += event.compositeScore
            }
            // All unordered tag pairs on this event co-occur.
            let sortedTags = event.tags.sorted()
            for i in 0..<sortedTags.count {
                for j in (i + 1)..<sortedTags.count {
                    let key = "\(sortedTags[i])::\(sortedTags[j])"
                    pairCount[key, default: 0] += 1
                    pairTimestamps[key, default: []].append(event.timestamp)
                }
            }
        }

        let nodes = tagCounts.map { tag, count in
            LUMGraphNode(tag: tag,
                         weight: count,
                         mood: Double(tagComposite[tag] ?? 0) / Double(count))
        }
        .sorted { $0.weight > $1.weight }

        let maxCount = max(1, pairCount.values.max() ?? 1)
        var edges: [LUMGraphEdge] = []

        for (key, count) in pairCount {
            let parts = key.components(separatedBy: "::")
            guard parts.count == 2 else { continue }

            let frequencyFactor = Double(count) / Double(maxCount)
            let proximityFactor = temporalProximity(pairTimestamps[key] ?? [])
            // Blend: 70% how often, 30% how tight in time.
            let strength = (frequencyFactor * 0.7) + (proximityFactor * 0.3)

            edges.append(LUMGraphEdge(source: parts[0],
                                      target: parts[1],
                                      coOccurrence: count,
                                      strength: strength))
        }
        edges.sort { $0.strength > $1.strength }

        // Precompute adjacency for layout / "related tags".
        var adjacency: [String: [String]] = [:]
        for edge in edges {
            adjacency[edge.source, default: []].append(edge.target)
            adjacency[edge.target, default: []].append(edge.source)
        }

        return LUMGraph(nodes: nodes, edges: edges, adjacency: adjacency)
    }

    /// 0...1 score: how temporally clustered a pair's shared events are. One
    /// occurrence is treated as maximally tight (1.0) — a strong but rare
    /// signal. Otherwise we average the gaps between consecutive shared events
    /// and map "tight" (≤1 day) toward 1 and "loose" (≥14 days) toward 0.
    private func temporalProximity(_ timestamps: [Date]) -> Double {
        guard timestamps.count > 1 else { return 1.0 }
        let sorted = timestamps.sorted()
        var gaps: [Double] = []
        for i in 1..<sorted.count {
            gaps.append(sorted[i].timeIntervalSince(sorted[i - 1]))
        }
        let meanGapDays = (gaps.average) / 86_400.0
        let reference = 14.0
        // Linear falloff, clamped.
        return max(0, min(1, 1 - (meanGapDays / reference)))
    }
}
