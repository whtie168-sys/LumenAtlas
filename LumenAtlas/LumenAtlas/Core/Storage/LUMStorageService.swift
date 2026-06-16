//
//  LUMStorageService.swift
//  LumenAtlas
//
//  Local-only persistence. The app makes no network requests by design, so this
//  is the single source of durable truth: atomically-written JSON files in the
//  app's Documents directory.
//

import Foundation

/// Abstracts the on-disk store so services depend on a protocol rather than a
/// concrete file layout — makes the event/tag services unit-testable with an
/// in-memory double.
protocol LUMStorageServing: AnyObject {
    func loadEvents() -> [LUMEvent]
    func saveEvents(_ events: [LUMEvent])
    func loadTags() -> [LUMTag]
    func saveTags(_ tags: [LUMTag])
    /// Raw JSON for the export feature.
    func exportableSnapshot() -> Data?
    /// Replace the whole store from imported JSON. Returns the parsed events.
    func replaceFromSnapshot(_ data: Data) throws -> [LUMEvent]
}

final class LUMStorageService: LUMStorageServing {

    enum StorageError: Error { case malformedSnapshot }

    /// The shape written to disk and used for import/export. Versioned so a
    /// future schema change can migrate rather than fail.
    private struct Snapshot: Codable {
        var version: Int
        var events: [LUMEvent]
        var tags: [LUMTag]
    }

    private static let currentVersion = 1
    private let eventsURL: URL
    private let tagsURL: URL

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    init(directory: URL? = nil) {
        let base = directory ?? FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.eventsURL = base.appendingPathComponent("lumen_events.json")
        self.tagsURL = base.appendingPathComponent("lumen_tags.json")
    }

    // MARK: Events

    func loadEvents() -> [LUMEvent] {
        guard let data = try? Data(contentsOf: eventsURL),
              let events = try? decoder.decode([LUMEvent].self, from: data) else {
            return []
        }
        return events
    }

    func saveEvents(_ events: [LUMEvent]) {
        guard let data = try? encoder.encode(events) else { return }
        try? data.write(to: eventsURL, options: .atomic)
    }

    // MARK: Tags

    func loadTags() -> [LUMTag] {
        guard let data = try? Data(contentsOf: tagsURL),
              let tags = try? decoder.decode([LUMTag].self, from: data) else {
            return []
        }
        return tags
    }

    func saveTags(_ tags: [LUMTag]) {
        guard let data = try? encoder.encode(tags) else { return }
        try? data.write(to: tagsURL, options: .atomic)
    }

    // MARK: Import / Export

    func exportableSnapshot() -> Data? {
        let snapshot = Snapshot(version: Self.currentVersion,
                                events: loadEvents(),
                                tags: loadTags())
        return try? encoder.encode(snapshot)
    }

    func replaceFromSnapshot(_ data: Data) throws -> [LUMEvent] {
        guard let snapshot = try? decoder.decode(Snapshot.self, from: data) else {
            throw StorageError.malformedSnapshot
        }
        saveEvents(snapshot.events)
        saveTags(snapshot.tags)
        return snapshot.events
    }
}
