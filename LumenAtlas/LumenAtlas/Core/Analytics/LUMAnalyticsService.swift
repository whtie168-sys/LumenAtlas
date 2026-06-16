//
//  LUMAnalyticsService.swift
//  LumenAtlas
//
//  The analytical core of the app. Pure functions over [LUMEvent] producing the
//  derived series, anomalies, distributions, rankings and clusters that every
//  analytics screen renders. No UIKit, no storage — just maths, so it can be
//  reasoned about and tested in isolation.
//

import Foundation

final class LUMAnalyticsService {

    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    // MARK: - Rolling average

    /// N-day rolling average of one axis.
    ///
    /// Events are first collapsed into per-day means (a day may hold several
    /// events), then a trailing window of `window` days is averaged at each
    /// step. Days with no data are skipped rather than treated as zero, so a
    /// gap doesn't drag the curve to the floor.
    func rollingAverage(for axis: LUMSignalAxis,
                        window: Int = 7,
                        events: [LUMEvent]) -> LUMTrendSeries {
        let daily = dailyMeans(for: axis, events: events)
        guard !daily.isEmpty else { return LUMTrendSeries(axis: axis, points: []) }

        // Ascending by day for a left-to-right time axis.
        let ordered = daily.sorted { $0.key < $1.key }
        var points: [LUMTrendPoint] = []

        for index in ordered.indices {
            let windowSlice = ordered[max(0, index - window + 1)...index]
            let mean = windowSlice.map(\.value).average
            points.append(LUMTrendPoint(date: ordered[index].key, value: mean))
        }
        return LUMTrendSeries(axis: axis, points: points)
    }

    // MARK: - Anomaly detection (spikes & peaks)

    /// Flags readings that sit more than `threshold` standard deviations from
    /// the axis mean. For stress (higherIsBetter == false) a positive deviation
    /// is a *spike* to warn about; for the positive axes it's a *peak* to
    /// celebrate. Low outliers on positive axes are also reported as concerns.
    func detectAnomalies(events: [LUMEvent],
                         threshold: Double = 1.6) -> [LUMAnomaly] {
        guard events.count >= 4 else { return [] }
        var anomalies: [LUMAnomaly] = []

        for axis in LUMSignalAxis.allCases {
            let values = events.map { Double($0.value(for: axis)) }
            let mean = values.average
            let sd = values.standardDeviation
            guard sd > 0.0001 else { continue }

            for event in events {
                let v = Double(event.value(for: axis))
                let z = (v - mean) / sd
                guard abs(z) >= threshold else { continue }

                let kind: LUMAnomaly.Kind
                if axis.higherIsBetter {
                    // High positive reading = peak; very low = spike (concern).
                    kind = z > 0 ? .peak : .spike
                } else {
                    // Stress: high = spike (concern); unusually low = peak (relief).
                    kind = z > 0 ? .spike : .peak
                }

                anomalies.append(LUMAnomaly(
                    id: UUID(),
                    axis: axis,
                    kind: kind,
                    date: event.timestamp,
                    value: event.value(for: axis),
                    deviation: z,
                    eventID: event.id
                ))
            }
        }
        // Strongest deviations first.
        return anomalies.sorted { abs($0.deviation) > abs($1.deviation) }
    }

    // MARK: - Distribution

    /// Buckets one axis into fixed 20-wide bins (0–19, 20–39, …, 80–100).
    func distribution(for axis: LUMSignalAxis, events: [LUMEvent]) -> LUMDistribution {
        let bounds = [(0, 19), (20, 39), (40, 59), (60, 79), (80, 100)]
        var counts = Array(repeating: 0, count: bounds.count)

        for event in events {
            let v = event.value(for: axis)
            if let bin = bounds.firstIndex(where: { v >= $0.0 && v <= $0.1 }) {
                counts[bin] += 1
            }
        }
        let buckets = zip(bounds, counts).map {
            LUMDistribution.Bucket(lowerBound: $0.0, upperBound: $0.1, count: $1)
        }
        return LUMDistribution(axis: axis, buckets: buckets, total: events.count)
    }

    // MARK: - Tag ranking

    /// Ranks tags by frequency, carrying the mean composite score of the events
    /// each tag appears on so the UI can colour by mood as well as size.
    func rankTags(events: [LUMEvent]) -> [LUMTagRank] {
        var counts: [String: Int] = [:]
        var compositeSums: [String: Int] = [:]

        for event in events {
            for tag in event.tags {
                counts[tag, default: 0] += 1
                compositeSums[tag, default: 0] += event.compositeScore
            }
        }
        return counts.map { tag, count in
            LUMTagRank(tag: tag,
                       count: count,
                       averageComposite: Double(compositeSums[tag] ?? 0) / Double(count))
        }
        .sorted { $0.count != $1.count ? $0.count > $1.count : $0.tag < $1.tag }
    }

    // MARK: - Temporal clustering

    /// Groups events whose timestamps fall within `gap` of one another into
    /// clusters ("episodes"). A simple single-link sweep over time-sorted
    /// events: start a new cluster whenever the gap to the previous event
    /// exceeds the threshold. Default gap is 6 hours.
    func clusterByTime(events: [LUMEvent], gap: TimeInterval = 6 * 3600) -> [LUMCluster] {
        guard !events.isEmpty else { return [] }
        let ordered = events.sorted { $0.timestamp < $1.timestamp }

        var clusters: [LUMCluster] = []
        var bucket: [LUMEvent] = [ordered[0]]

        func flush() {
            guard let first = bucket.first, let last = bucket.last else { return }
            let composites = bucket.map { Double($0.compositeScore) }
            clusters.append(LUMCluster(
                id: UUID(),
                eventIDs: bucket.map(\.id),
                start: first.timestamp,
                end: last.timestamp,
                averageComposite: composites.average
            ))
        }

        for event in ordered.dropFirst() {
            let previous = bucket.last!.timestamp
            if event.timestamp.timeIntervalSince(previous) <= gap {
                bucket.append(event)
            } else {
                flush()
                bucket = [event]
            }
        }
        flush()
        // Largest, most significant episodes first.
        return clusters.sorted { $0.size > $1.size }
    }

    // MARK: - Private helpers

    /// Collapse events into one mean value per calendar day for the given axis.
    private func dailyMeans(for axis: LUMSignalAxis,
                            events: [LUMEvent]) -> [Date: Double] {
        var grouped: [Date: [Double]] = [:]
        for event in events {
            let day = calendar.startOfDay(for: event.timestamp)
            grouped[day, default: []].append(Double(event.value(for: axis)))
        }
        return grouped.mapValues { $0.average }
    }
}
