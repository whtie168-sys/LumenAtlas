//
//  LUMExportService.swift
//  LumenAtlas
//
//  Produces shareable artifacts from the local store: a full JSON backup and a
//  human-readable plain-text report summarising the analytics. No data leaves
//  the device unless the user explicitly invokes the system share sheet.
//

import Foundation

protocol LUMExportServing: AnyObject {
    /// Full machine-readable backup written to a temp file; returns its URL.
    func exportJSON() -> URL?
    /// Human-readable analytics digest written to a temp file; returns its URL.
    func exportReport(events: [LUMEvent], analytics: LUMAnalyticsService) -> URL?
}

final class LUMExportService: LUMExportServing {

    private let storage: LUMStorageServing

    init(storage: LUMStorageServing) {
        self.storage = storage
    }

    func exportJSON() -> URL? {
        guard let data = storage.exportableSnapshot() else { return nil }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("LumenAtlas-Backup.json")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    func exportReport(events: [LUMEvent], analytics: LUMAnalyticsService) -> URL? {
        let text = Self.renderReport(events: events, analytics: analytics)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("LumenAtlas-Report.txt")
        do {
            try text.data(using: .utf8)?.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }

    // MARK: Report rendering

    private static func renderReport(events: [LUMEvent],
                                     analytics: LUMAnalyticsService) -> String {
        var lines: [String] = []
        lines.append("LUMEN ATLAS — SIGNAL REPORT")
        lines.append("Generated locally • \(events.count) events")
        lines.append(String(repeating: "=", count: 40))
        lines.append("")

        for axis in LUMSignalAxis.allCases {
            let series = analytics.rollingAverage(for: axis, window: 7, events: events)
            let arrow: String
            switch series.direction {
            case .rising:  arrow = "▲ rising"
            case .falling: arrow = "▼ falling"
            case .flat:    arrow = "▬ steady"
            }
            let latest = series.points.last?.value ?? 0
            lines.append("\(axis.glyph) \(axis.title): \(Int(latest)) (7d avg) — \(arrow)")
        }

        lines.append("")
        let anomalies = analytics.detectAnomalies(events: events)
        lines.append("Anomalies detected: \(anomalies.count)")
        for anomaly in anomalies.prefix(10) {
            let kind = anomaly.kind == .spike ? "SPIKE" : "PEAK"
            lines.append("  • \(anomaly.axis.title) \(kind) — value \(anomaly.value), "
                         + String(format: "%.1fσ", anomaly.deviation))
        }

        lines.append("")
        let ranked = analytics.rankTags(events: events).prefix(10)
        lines.append("Top tags:")
        for rank in ranked {
            lines.append("  • \(rank.tag): \(rank.count) events, "
                         + String(format: "avg %.0f", rank.averageComposite))
        }

        return lines.joined(separator: "\n")
    }
}
