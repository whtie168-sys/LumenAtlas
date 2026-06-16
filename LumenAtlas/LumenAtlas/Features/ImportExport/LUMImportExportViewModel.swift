//
//  LUMImportExportViewModel.swift
//  LumenAtlas
//
//  Coordinates local backup/restore and report generation. All work goes
//  through the export/import services; nothing touches the network.
//

import Foundation

final class LUMImportExportViewModel {

    private let container: LUMServiceContainer

    init(container: LUMServiceContainer) {
        self.container = container
    }

    var eventCount: Int { container.events.events.count }

    /// JSON backup file URL for the share sheet.
    func makeBackupFile() -> URL? {
        container.export.exportJSON()
    }

    /// Plain-text analytics report file URL for the share sheet.
    func makeReportFile() -> URL? {
        container.export.exportReport(events: container.events.events,
                                      analytics: container.analytics)
    }

    /// Restore from a picked backup file. Reloads the in-memory store on success.
    func restore(from url: URL) -> Result<Int, Error> {
        do {
            let restored = try container.importer.importBackup(from: url)
            container.events.reload(with: restored)
            return .success(restored.count)
        } catch {
            return .failure(error)
        }
    }

    /// Replace all data with a fresh sample set (useful for demos/resets).
    func loadSampleData() {
        let samples = container.importer.makeSampleData()
        // Clear existing then add.
        for event in container.events.events { container.events.delete(id: event.id) }
        for event in samples { container.events.add(event) }
    }
}
