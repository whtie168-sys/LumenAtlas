//
//  LUMServiceContainer.swift
//  LumenAtlas
//
//  A single composition root. Every service is constructed once here and passed
//  explicitly into the objects that need it (constructor injection), so there
//  are no global singletons and the dependency graph is visible in one place.
//

import Foundation

final class LUMServiceContainer {

    let storage: LUMStorageServing
    let events: LUMEventService
    let analytics: LUMAnalyticsService
    let graph: LUMGraphService
    let security: LUMSecurityServing
    let export: LUMExportServing
    let importer: LUMImportServing

    init() {
        let storage = LUMStorageService()
        self.storage = storage
        self.events = LUMEventService(storage: storage)
        self.analytics = LUMAnalyticsService()
        self.graph = LUMGraphService()
        self.security = LUMSecurityService()
        self.export = LUMExportService(storage: storage)
        self.importer = LUMImportService(storage: storage)
    }

    /// First-launch seeding: if the store is empty, populate it with sample data
    /// so analytics and the graph are immediately meaningful. Tracked via a
    /// defaults flag so a user who deletes everything isn't re-seeded.
    func seedIfNeeded(defaults: UserDefaults = .standard) {
        let key = "lumen.didSeed"
        guard !defaults.bool(forKey: key) else { return }
        defaults.set(true, forKey: key)

        guard events.events.isEmpty else { return }
        let samples = importer.makeSampleData()
        for event in samples { events.add(event) }
    }
}
