//
//  LUMSearchViewModel.swift
//  LumenAtlas
//
//  Full-text + tag + signal-threshold search over the event store. Filtering is
//  done in-memory; the dataset is personal-scale so this stays instant.
//

import Foundation

final class LUMSearchViewModel {

    private let eventService: LUMEventServing

    /// Free-text query matched against title, note and tags.
    var query: String = "" { didSet { recompute() } }
    /// Optional axis filter: only events whose axis value is >= threshold.
    var axisFilter: LUMSignalAxis? { didSet { recompute() } }
    var threshold: Int = 0 { didSet { recompute() } }

    var onChange: (() -> Void)?
    private(set) var results: [LUMEvent] = []

    init(eventService: LUMEventServing) {
        self.eventService = eventService
        recompute()
    }

    /// Tags available as quick filters, ranked by frequency.
    var suggestedTags: [String] {
        Array(Set(eventService.events.flatMap(\.tags)))
            .sorted()
            .prefix(12)
            .map { $0 }
    }

    private func recompute() {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        results = eventService.events.filter { event in
            let textMatch = trimmed.isEmpty
                || event.title.lowercased().contains(trimmed)
                || event.note.lowercased().contains(trimmed)
                || event.tags.contains { $0.contains(trimmed) }

            let axisMatch: Bool
            if let axis = axisFilter {
                axisMatch = event.value(for: axis) >= threshold
            } else {
                axisMatch = true
            }
            return textMatch && axisMatch
        }
        onChange?()
    }
}
