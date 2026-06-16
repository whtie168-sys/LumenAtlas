//
//  LUMAnalyticsModels.swift
//  LumenAtlas
//
//  Value types returned by the analytics engine. These are pure data — no
//  computation lives here. The engine in `LUMAnalyticsService` produces them and
//  the ViewModels consume them, which keeps the math testable in isolation.
//

import Foundation

/// One point on a derived series (e.g. a day's rolling average).
struct LUMTrendPoint: Equatable {
    let date: Date
    let value: Double
}

/// A full derived series for one axis plus a coarse direction summary.
struct LUMTrendSeries: Equatable {
    let axis: LUMSignalAxis
    let points: [LUMTrendPoint]

    enum Direction { case rising, falling, flat }

    /// Compares the mean of the first third of the window to the last third.
    /// More robust than first-vs-last when the data is noisy.
    var direction: Direction {
        guard points.count >= 3 else { return .flat }
        let third = max(1, points.count / 3)
        let head = points.prefix(third).map(\.value).average
        let tail = points.suffix(third).map(\.value).average
        let delta = tail - head
        if delta > 3 { return .rising }
        if delta < -3 { return .falling }
        return .flat
    }
}

/// A detected anomaly — either a stress spike or an energy/focus peak. Surfaced
/// on the dashboard and in the insight engine.
struct LUMAnomaly: Equatable, Identifiable {
    enum Kind { case spike, peak }
    let id: UUID
    let axis: LUMSignalAxis
    let kind: Kind
    let date: Date
    let value: Int
    /// How many standard deviations from the mean this reading sat.
    let deviation: Double
    let eventID: UUID
}

/// Distribution of one axis across fixed buckets (used by the focus histogram).
struct LUMDistribution: Equatable {
    struct Bucket: Equatable {
        let lowerBound: Int
        let upperBound: Int
        let count: Int
        var label: String { "\(lowerBound)–\(upperBound)" }
    }
    let axis: LUMSignalAxis
    let buckets: [Bucket]
    let total: Int
}

/// A ranked tag with the supporting counts the UI needs.
struct LUMTagRank: Equatable, Identifiable {
    var id: String { tag }
    let tag: String
    let count: Int
    /// Mean composite score across the events carrying this tag — lets the UI
    /// show whether a tag tends to coincide with good or bad days.
    let averageComposite: Double
}

/// A cluster of events grouped by a sliding time window. Represents a "session"
/// or "episode" of activity rather than isolated points.
struct LUMCluster: Equatable, Identifiable {
    let id: UUID
    let eventIDs: [UUID]
    let start: Date
    let end: Date
    let averageComposite: Double

    var span: TimeInterval { end.timeIntervalSince(start) }
    var size: Int { eventIDs.count }
}

extension Array where Element == Double {
    var average: Double { isEmpty ? 0 : reduce(0, +) / Double(count) }

    /// Population standard deviation. Used by the anomaly detector.
    var standardDeviation: Double {
        guard count > 1 else { return 0 }
        let mean = average
        let variance = map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(count)
        return variance.squareRoot()
    }
}
