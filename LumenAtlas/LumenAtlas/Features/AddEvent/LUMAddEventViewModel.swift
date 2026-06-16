//
//  LUMAddEventViewModel.swift
//  LumenAtlas
//
//  Backs the capture/edit form. Holds the in-progress draft, validates it, and
//  commits a new or updated event to the store. Works in two modes — create and
//  edit — sharing the same UI.
//

import Foundation

final class LUMAddEventViewModel {

    enum Mode { case create, edit(LUMEvent) }

    private let eventService: LUMEventServing
    let mode: Mode

    // Draft fields, seeded from the edited event when present.
    var title: String
    var emotion: Int
    var energy: Int
    var stress: Int
    var focus: Int
    var tagsText: String
    var note: String

    init(eventService: LUMEventServing, editing: LUMEvent?) {
        self.eventService = eventService
        if let event = editing {
            self.mode = .edit(event)
            self.title = event.title
            self.emotion = event.emotion
            self.energy = event.energy
            self.stress = event.stress
            self.focus = event.focus
            self.tagsText = event.tags.joined(separator: ", ")
            self.note = event.note
        } else {
            self.mode = .create
            self.title = ""
            self.emotion = 60
            self.energy = 60
            self.stress = 30
            self.focus = 55
            self.tagsText = ""
            self.note = ""
        }
    }

    var screenTitle: String {
        switch mode {
        case .create: return "New Signal"
        case .edit:   return "Edit Signal"
        }
    }

    /// A title is the only hard requirement; signals always have valid defaults.
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func value(for axis: LUMSignalAxis) -> Int {
        switch axis {
        case .emotion: return emotion
        case .energy:  return energy
        case .stress:  return stress
        case .focus:   return focus
        }
    }

    func setValue(_ value: Int, for axis: LUMSignalAxis) {
        switch axis {
        case .emotion: emotion = value
        case .energy:  energy = value
        case .stress:  stress = value
        case .focus:   focus = value
        }
    }

    /// Parses the comma/space-separated tag field into normalised slugs.
    private func parsedTags() -> [String] {
        let raw = tagsText
            .components(separatedBy: CharacterSet(charactersIn: ",\n"))
            .flatMap { $0.components(separatedBy: " ") }
        return LUMEvent.normalize(raw)
    }

    /// Commit the draft. Returns the persisted event, or nil if invalid.
    @discardableResult
    func save() -> LUMEvent? {
        guard canSave else { return nil }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        switch mode {
        case .create:
            let event = LUMEvent(title: trimmedTitle,
                                 emotion: emotion, energy: energy,
                                 stress: stress, focus: focus,
                                 tags: parsedTags(), note: note)
            return eventService.add(event)
        case .edit(let existing):
            let updated = existing.updating(title: trimmedTitle,
                                            emotion: emotion, energy: energy,
                                            stress: stress, focus: focus,
                                            tags: parsedTags(), note: note)
            eventService.update(updated)
            return updated
        }
    }
}
