//
//  LUMImportService.swift
//  LumenAtlas
//
//  Restores the store from a previously-exported JSON backup, or seeds a fresh
//  install with a representative dataset so first-run users land on a populated,
//  meaningful dashboard rather than empty charts.
//

import Foundation

protocol LUMImportServing: AnyObject {
    /// Parse and apply a backup file. Returns the restored events on success.
    func importBackup(from url: URL) throws -> [LUMEvent]
    /// Generate a deterministic-but-realistic sample dataset.
    func makeSampleData() -> [LUMEvent]
}

final class LUMImportService: LUMImportServing {

    enum ImportError: Error { case unreadable }

    private let storage: LUMStorageServing

    init(storage: LUMStorageServing) {
        self.storage = storage
    }

    func importBackup(from url: URL) throws -> [LUMEvent] {
        // Coordinate access for documents that arrive from outside the sandbox
        // (Files app, share sheet) which require a security scope.
        let scoped = url.startAccessingSecurityScopedResource()
        defer { if scoped { url.stopAccessingSecurityScopedResource() } }

        guard let data = try? Data(contentsOf: url) else {
            throw ImportError.unreadable
        }
        return try storage.replaceFromSnapshot(data)
    }

    /// Builds ~6 weeks of plausible events. The values are shaped with weekly
    /// rhythms and a couple of deliberate stress episodes so the analytics
    /// engine has real structure to find (spikes, clusters, tag correlations).
    func makeSampleData() -> [LUMEvent] {
        let calendar = Calendar.current
        let now = Date()
        var events: [LUMEvent] = []

        let templates: [(title: String, tags: [String])] = [
            ("Morning routine", ["health", "morning"]),
            ("Deep work block", ["work", "focus"]),
            ("Team sync", ["work", "social"]),
            ("Gym session", ["health", "exercise"]),
            ("Evening reading", ["learning", "calm"]),
            ("Family dinner", ["family", "social"]),
            ("Project deadline", ["work", "deadline"]),
            ("Weekend hike", ["health", "nature", "calm"])
        ]

        for dayOffset in 0..<42 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: now) else { continue }
            // 1–3 events per day, varying with a weekly cadence.
            let weekday = calendar.component(.weekday, from: day)
            let isWeekend = (weekday == 1 || weekday == 7)
            let count = isWeekend ? 1 : (dayOffset % 3 == 0 ? 3 : 2)

            for slot in 0..<count {
                let template = templates[(dayOffset + slot) % templates.count]
                // A synthetic deadline week around day 14–18 drives stress up.
                let crunch = (14...18).contains(dayOffset)

                let baseEnergy = isWeekend ? 70 : 55
                let stress = crunch ? 78 + (slot * 5) : 30 + (dayOffset % 20)
                let focus = template.tags.contains("focus") ? 80 : 50 + (slot * 8)
                let emotion = isWeekend ? 75 : (crunch ? 40 : 60 + (dayOffset % 15))

                guard let timestamp = calendar.date(bySettingHour: 8 + slot * 5,
                                                     minute: (dayOffset * 7) % 60,
                                                     second: 0,
                                                     of: day) else { continue }

                events.append(LUMEvent(
                    title: template.title,
                    timestamp: timestamp,
                    emotion: emotion,
                    energy: baseEnergy + (dayOffset % 25) - 10,
                    stress: stress,
                    focus: focus,
                    tags: template.tags,
                    note: crunch ? "High-pressure period." : ""
                ))
            }
        }
        return events
    }
}
