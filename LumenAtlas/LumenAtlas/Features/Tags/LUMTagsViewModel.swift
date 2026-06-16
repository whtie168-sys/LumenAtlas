//
//  LUMTagsViewModel.swift
//  LumenAtlas
//
//  Backs the tag-management screen: lists managed tags with usage counts,
//  supports pinning, recolouring and deletion (which also strips the tag from
//  every event that carries it).
//

import Foundation

final class LUMTagsViewModel {

    struct TagItem {
        let tag: LUMTag
        let usageCount: Int
    }

    private let eventService: LUMEventServing
    private var token: LUMSubscriptionToken?

    var onChange: (() -> Void)?
    private(set) var items: [TagItem] = []

    init(eventService: LUMEventServing) {
        self.eventService = eventService
        token = eventService.changes.subscribe { [weak self] in self?.rebuild() }
        rebuild()
    }

    var isEmpty: Bool { items.isEmpty }

    private func rebuild() {
        var usage: [String: Int] = [:]
        for event in eventService.events {
            for slug in event.tags { usage[slug, default: 0] += 1 }
        }
        items = eventService.tags
            .map { TagItem(tag: $0, usageCount: usage[$0.slug] ?? 0) }
            // Pinned first, then by usage, then alphabetically.
            .sorted {
                if $0.tag.isPinned != $1.tag.isPinned { return $0.tag.isPinned }
                if $0.usageCount != $1.usageCount { return $0.usageCount > $1.usageCount }
                return $0.tag.slug < $1.tag.slug
            }
        onChange?()
    }

    func togglePin(_ item: TagItem) {
        eventService.upsertTag(item.tag.updating(isPinned: !item.tag.isPinned))
    }

    func cycleColor(_ item: TagItem) {
        let next = (item.tag.colorIndex + 1) % LUMPalette.tagColorCount
        eventService.upsertTag(item.tag.updating(colorIndex: next))
    }

    func delete(_ item: TagItem) {
        eventService.deleteTag(slug: item.tag.slug)
    }
}
