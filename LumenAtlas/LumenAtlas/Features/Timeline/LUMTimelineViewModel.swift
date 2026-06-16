//
//  LUMTimelineViewModel.swift
//  LumenAtlas
//
//  Groups events into day sections for a sectioned timeline, and exposes delete.
//

import Foundation
import UIKit

final class LUMTimelineViewModel {

    struct Section {
        let date: Date
        let title: String
        let events: [LUMEvent]
    }

    private let eventService: LUMEventServing
    private var token: LUMSubscriptionToken?

    var onChange: (() -> Void)?
    private(set) var sections: [Section] = []

    init(eventService: LUMEventServing) {
        self.eventService = eventService
        token = eventService.changes.subscribe { [weak self] in self?.rebuild() }
        rebuild()
    }

    var isEmpty: Bool { sections.isEmpty }

    func event(at indexPath: IndexPath) -> LUMEvent {
        sections[indexPath.section].events[indexPath.row]
    }

    func delete(at indexPath: IndexPath) {
        let event = self.event(at: indexPath)
        eventService.delete(id: event.id)
    }

    private func rebuild() {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: eventService.events) {
            calendar.startOfDay(for: $0.timestamp)
        }
        sections = grouped
            .map { day, events in
                Section(date: day,
                        title: Self.sectionTitle(for: day),
                        events: events.sorted { $0.timestamp > $1.timestamp })
            }
            .sorted { $0.date > $1.date }
        onChange?()
    }

    private static func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        return Self.dateFormatter.string(from: date)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()

    static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f
    }()
}
