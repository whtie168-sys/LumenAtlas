//
//  LUMEvent.swift
//  LumenAtlas
//
//  The atomic record of the system. Everything else — timelines, analytics,
//  the relationship graph — is derived from a collection of these.
//

import Foundation

/// A single captured moment carrying four signal readings plus contextual
/// metadata. Immutable by design: edits produce a new value via `updating(...)`,
/// which keeps the store easy to reason about and makes diffing cheap.
struct LUMEvent: Codable, Equatable, Identifiable {

    let id: UUID
    let title: String
    let timestamp: Date

    let emotion: Int
    let energy: Int
    let stress: Int
    let focus: Int

    /// Lower-cased, de-duplicated tag slugs. Stored normalised so the graph and
    /// frequency analysis never have to worry about "Work" vs "work".
    let tags: [String]
    let note: String

    init(id: UUID = UUID(),
         title: String,
         timestamp: Date = Date(),
         emotion: Int,
         energy: Int,
         stress: Int,
         focus: Int,
         tags: [String] = [],
         note: String = "") {
        self.id = id
        self.title = title
        self.timestamp = timestamp
        self.emotion = LUMSignalReading(axis: .emotion, value: emotion).value
        self.energy = LUMSignalReading(axis: .energy, value: energy).value
        self.stress = LUMSignalReading(axis: .stress, value: stress).value
        self.focus = LUMSignalReading(axis: .focus, value: focus).value
        self.tags = LUMEvent.normalize(tags)
        self.note = note
    }

    /// Reads a single axis off the event without a four-way switch at every call site.
    func value(for axis: LUMSignalAxis) -> Int {
        switch axis {
        case .emotion: return emotion
        case .energy:  return energy
        case .stress:  return stress
        case .focus:   return focus
        }
    }

    /// Returns a copy with selected fields replaced. Used by the edit flow.
    func updating(title: String? = nil,
                  emotion: Int? = nil,
                  energy: Int? = nil,
                  stress: Int? = nil,
                  focus: Int? = nil,
                  tags: [String]? = nil,
                  note: String? = nil) -> LUMEvent {
        LUMEvent(id: id,
                 title: title ?? self.title,
                 timestamp: timestamp,
                 emotion: emotion ?? self.emotion,
                 energy: energy ?? self.energy,
                 stress: stress ?? self.stress,
                 focus: focus ?? self.focus,
                 tags: tags ?? self.tags,
                 note: note ?? self.note)
    }

    /// A composite 0...100 "vitality" score: the average of the positive axes
    /// minus the drag of stress. Used as the headline number on the dashboard.
    var compositeScore: Int {
        let positive = Double(emotion + energy + focus) / 3.0
        let drag = Double(stress) * 0.5
        return Int((positive - drag + 50).rounded().clampedToSignalRange)
    }

    /// Tags are the join key for the graph, so normalisation has to be total and
    /// deterministic: trim, lower-case, drop empties, and de-duplicate while
    /// preserving first-seen order.
    static func normalize(_ raw: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for tag in raw {
            let slug = tag.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !slug.isEmpty, !seen.contains(slug) else { continue }
            seen.insert(slug)
            result.append(slug)
        }
        return result
    }
}

extension Double {
    /// Clamp helper shared by the scoring math.
    var clampedToSignalRange: Double { min(max(self, 0), 100) }
}
