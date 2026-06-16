//
//  LUMSettingsViewModel.swift
//  LumenAtlas
//
//  Lightweight backing for the settings list: exposes summary state (event
//  count, PIN status) and the row model the VC renders.
//

import Foundation

final class LUMSettingsViewModel {

    struct Row {
        let icon: String
        let title: String
        let subtitle: String
        let action: Action
    }

    enum Action { case statistics, tags, pin, importExport, about }

    private let container: LUMServiceContainer

    init(container: LUMServiceContainer) {
        self.container = container
    }

    var eventCount: Int { container.events.events.count }
    var tagCount: Int { container.events.tags.count }
    var isPINEnabled: Bool { container.security.isPINEnabled }

    func rows() -> [Row] {
        [
            Row(icon: "chart.bar.fill", title: "Statistics",
                subtitle: "\(eventCount) signals logged", action: .statistics),
            Row(icon: "tag.fill", title: "Manage Tags",
                subtitle: "\(tagCount) tags", action: .tags),
            Row(icon: "lock.fill", title: "Privacy Lock",
                subtitle: isPINEnabled ? "PIN enabled" : "Off", action: .pin),
            Row(icon: "arrow.up.arrow.down.circle.fill", title: "Import / Export",
                subtitle: "Local backup & restore", action: .importExport),
            Row(icon: "info.circle.fill", title: "About",
                subtitle: "Lumen Atlas", action: .about)
        ]
    }
}
