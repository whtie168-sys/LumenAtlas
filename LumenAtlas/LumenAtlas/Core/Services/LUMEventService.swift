//
//  LUMEventService.swift
//  LumenAtlas
//
//  The in-memory authority for events and tags. Holds the working set, performs
//  mutations, persists through the storage layer, and broadcasts changes so any
//  number of screens stay in sync without knowing about each other.
//

import Foundation

/// Lightweight multicast so ViewModels can react to store mutations. A plain
/// closure registry is enough here — no Combine dependency, no KVO ceremony.
final class LUMObservation {
    private var handlers: [UUID: () -> Void] = [:]

    func subscribe(_ handler: @escaping () -> Void) -> LUMSubscriptionToken {
        let id = UUID()
        handlers[id] = handler
        return LUMSubscriptionToken { [weak self] in self?.handlers[id] = nil }
    }

    func emit() { handlers.values.forEach { $0() } }
}

/// RAII-style unsubscribe: hold the token for as long as you want the
/// subscription, drop it to detach. Avoids dangling closures on dead VMs.
final class LUMSubscriptionToken {
    private let onCancel: () -> Void
    init(_ onCancel: @escaping () -> Void) { self.onCancel = onCancel }
    deinit { onCancel() }
}

protocol LUMEventServing: AnyObject {
    var events: [LUMEvent] { get }
    var tags: [LUMTag] { get }
    var changes: LUMObservation { get }

    @discardableResult func add(_ event: LUMEvent) -> LUMEvent
    func update(_ event: LUMEvent)
    func delete(id: UUID)
    func event(with id: UUID) -> LUMEvent?

    func upsertTag(_ tag: LUMTag)
    func deleteTag(slug: String)
}

final class LUMEventService: LUMEventServing {

    let changes = LUMObservation()

    /// Sorted newest-first; every mutation re-establishes this invariant so the
    /// timeline and dashboard can consume `events` directly.
    private(set) var events: [LUMEvent] = []
    private(set) var tags: [LUMTag] = []

    private let storage: LUMStorageServing

    init(storage: LUMStorageServing) {
        self.storage = storage
        self.events = storage.loadEvents().sorted { $0.timestamp > $1.timestamp }
        self.tags = storage.loadTags()
        reconcileTags()
    }

    // MARK: Events

    @discardableResult
    func add(_ event: LUMEvent) -> LUMEvent {
        events.append(event)
        events.sort { $0.timestamp > $1.timestamp }
        registerImplicitTags(from: event)
        persistAndNotify()
        return event
    }

    func update(_ event: LUMEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else { return }
        events[index] = event
        events.sort { $0.timestamp > $1.timestamp }
        registerImplicitTags(from: event)
        persistAndNotify()
    }

    func delete(id: UUID) {
        events.removeAll { $0.id == id }
        persistAndNotify()
    }

    func event(with id: UUID) -> LUMEvent? {
        events.first { $0.id == id }
    }

    // MARK: Tags

    func upsertTag(_ tag: LUMTag) {
        if let index = tags.firstIndex(where: { $0.slug == tag.slug }) {
            tags[index] = tag
        } else {
            tags.append(tag)
        }
        storage.saveTags(tags)
        changes.emit()
    }

    func deleteTag(slug: String) {
        tags.removeAll { $0.slug == slug }
        storage.saveTags(tags)
        changes.emit()
    }

    /// Replace the entire working set after an import.
    func reload(with events: [LUMEvent]) {
        self.events = events.sorted { $0.timestamp > $1.timestamp }
        self.tags = storage.loadTags()
        reconcileTags()
        changes.emit()
    }

    // MARK: Private

    private func persistAndNotify() {
        storage.saveEvents(events)
        storage.saveTags(tags)
        changes.emit()
    }

    /// Any tag typed on an event but not yet managed gets an auto-created entry
    /// so it appears in the tag manager with a deterministic colour.
    private func registerImplicitTags(from event: LUMEvent) {
        for slug in event.tags where !tags.contains(where: { $0.slug == slug }) {
            let colorIndex = abs(slug.hashValue) % LUMPalette.tagColorCount
            tags.append(LUMTag(displayName: slug, colorIndex: colorIndex))
        }
    }

    /// On launch, make sure every tag referenced by an event exists in the tag
    /// list — guards against a hand-edited or partially-imported store.
    private func reconcileTags() {
        let referenced = Set(events.flatMap(\.tags))
        for slug in referenced where !tags.contains(where: { $0.slug == slug }) {
            let colorIndex = abs(slug.hashValue) % LUMPalette.tagColorCount
            tags.append(LUMTag(displayName: slug, colorIndex: colorIndex))
        }
    }
}
