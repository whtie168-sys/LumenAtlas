//
//  CDCKDataStore.swift
//  TechRefPro
//
//  Central observable store. Owns all reference data, favorites and
//  calculation history. Persists everything to UserDefaults as JSON.
//  Seeds preset data on first launch.
//

import Foundation
import Combine

/// The single source of truth for reference data, favorites and history.
/// Backed by `UserDefaults` with JSON encoding. No network, no third-party.
final class CDCKDataStore: ObservableObject {

    // MARK: Published collections

    @Published private(set) var cables: [CDCKCableEntry] = []
    @Published private(set) var wireGauges: [CDCKWireGauge] = []
    @Published private(set) var breakers: [CDCKBreakerSpec] = []
    @Published private(set) var motors: [CDCKMotorParam] = []
    @Published private(set) var safety: [CDCKSafetyStandard] = []

    @Published private(set) var favorites: [CDCKFavorite] = []
    @Published private(set) var history: [CDCKCalculationHistory] = []
    @Published private(set) var favoriteFormulaIDs: Set<String> = []

    // MARK: Persistence keys

    private enum Key {
        static let cables = "cdck.cables"
        static let wireGauges = "cdck.wireGauges"
        static let breakers = "cdck.breakers"
        static let motors = "cdck.motors"
        static let safety = "cdck.safety"
        static let favorites = "cdck.favorites"
        static let history = "cdck.history"
        static let favoriteFormulas = "cdck.favoriteFormulas"
        static let seeded = "cdck.didSeedPresetData.v1"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: Init

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        loadOrSeed()
    }

    // MARK: First-launch seeding

    private func loadOrSeed() {
        if !defaults.bool(forKey: Key.seeded) {
            cables = CDCKPresetData.cables()
            wireGauges = CDCKPresetData.wireGauges()
            breakers = CDCKPresetData.breakers()
            motors = CDCKPresetData.motors()
            safety = CDCKPresetData.safety()
            persistAll()
            defaults.set(true, forKey: Key.seeded)
        } else {
            cables = decode(Key.cables) ?? CDCKPresetData.cables()
            wireGauges = decode(Key.wireGauges) ?? CDCKPresetData.wireGauges()
            breakers = decode(Key.breakers) ?? CDCKPresetData.breakers()
            motors = decode(Key.motors) ?? CDCKPresetData.motors()
            safety = decode(Key.safety) ?? CDCKPresetData.safety()
            favorites = decode(Key.favorites) ?? []
            history = decode(Key.history) ?? []
            if let raw: [String] = decode(Key.favoriteFormulas) {
                favoriteFormulaIDs = Set(raw)
            }
        }
    }

    // MARK: Encoding helpers

    private func decode<T: Decodable>(_ key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    private func encode<T: Encodable>(_ value: T, _ key: String) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private func persistAll() {
        encode(cables, Key.cables)
        encode(wireGauges, Key.wireGauges)
        encode(breakers, Key.breakers)
        encode(motors, Key.motors)
        encode(safety, Key.safety)
        encode(favorites, Key.favorites)
        encode(history, Key.history)
        encode(Array(favoriteFormulaIDs), Key.favoriteFormulas)
    }

    // MARK: - Favorites

    /// Returns true if an item of the given type and id is currently favorited.
    func isFavorite(_ type: CDCKFavoriteType, _ referenceId: UUID) -> Bool {
        favorites.contains { $0.type == type.rawValue && $0.referenceId == referenceId }
    }

    /// Toggles a favorite for the given typed reference.
    func toggleFavorite(_ type: CDCKFavoriteType, _ referenceId: UUID) {
        if let idx = favorites.firstIndex(where: { $0.type == type.rawValue && $0.referenceId == referenceId }) {
            favorites.remove(at: idx)
        } else {
            favorites.append(CDCKFavorite(type: type, referenceId: referenceId))
        }
        encode(favorites, Key.favorites)
    }

    func removeFavorite(_ favorite: CDCKFavorite) {
        favorites.removeAll { $0.id == favorite.id }
        encode(favorites, Key.favorites)
    }

    func clearFavorites() {
        favorites.removeAll()
        favoriteFormulaIDs.removeAll()
        encode(favorites, Key.favorites)
        encode(Array(favoriteFormulaIDs), Key.favoriteFormulas)
    }

    // MARK: Calculator favorites (keyed by stable string id)

    func isFavoriteFormula(_ id: String) -> Bool {
        favoriteFormulaIDs.contains(id)
    }

    func toggleFavoriteFormula(_ id: String) {
        if favoriteFormulaIDs.contains(id) {
            favoriteFormulaIDs.remove(id)
        } else {
            favoriteFormulaIDs.insert(id)
        }
        encode(Array(favoriteFormulaIDs), Key.favoriteFormulas)
    }

    // MARK: Favorite resolution (for the Favorites screen)

    func favoriteCables() -> [CDCKCableEntry] {
        let ids = favoriteIDs(for: .cable)
        return cables.filter { ids.contains($0.id) }
    }
    func favoriteWireGauges() -> [CDCKWireGauge] {
        let ids = favoriteIDs(for: .wireGauge)
        return wireGauges.filter { ids.contains($0.id) }
    }
    func favoriteBreakers() -> [CDCKBreakerSpec] {
        let ids = favoriteIDs(for: .breaker)
        return breakers.filter { ids.contains($0.id) }
    }
    func favoriteMotors() -> [CDCKMotorParam] {
        let ids = favoriteIDs(for: .motor)
        return motors.filter { ids.contains($0.id) }
    }
    func favoriteSafety() -> [CDCKSafetyStandard] {
        let ids = favoriteIDs(for: .safety)
        return safety.filter { ids.contains($0.id) }
    }

    private func favoriteIDs(for type: CDCKFavoriteType) -> Set<UUID> {
        Set(favorites.filter { $0.type == type.rawValue }.map { $0.referenceId })
    }

    var totalFavoriteCount: Int { favorites.count + favoriteFormulaIDs.count }

    // MARK: - History

    /// Appends a calculation to the history log (most recent first).
    func addHistory(_ entry: CDCKCalculationHistory) {
        history.insert(entry, at: 0)
        // Keep the log bounded to a sensible size.
        if history.count > 200 { history = Array(history.prefix(200)) }
        encode(history, Key.history)
    }

    func deleteHistory(_ entry: CDCKCalculationHistory) {
        history.removeAll { $0.id == entry.id }
        encode(history, Key.history)
    }

    func deleteHistory(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        encode(history, Key.history)
    }

    func clearHistory() {
        history.removeAll()
        encode(history, Key.history)
    }

    // MARK: - Reset (used by Settings)

    /// Restores all reference data to the bundled presets and wipes user data.
    func resetToDefaults() {
        cables = CDCKPresetData.cables()
        wireGauges = CDCKPresetData.wireGauges()
        breakers = CDCKPresetData.breakers()
        motors = CDCKPresetData.motors()
        safety = CDCKPresetData.safety()
        favorites = []
        history = []
        favoriteFormulaIDs = []
        persistAll()
    }
}
