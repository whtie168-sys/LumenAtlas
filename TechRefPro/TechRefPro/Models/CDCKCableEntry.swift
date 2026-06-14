//
//  CDCKCableEntry.swift
//  TechRefPro
//
//  One row in the cable ampacity reference table.
//

import Foundation

/// A single conductor ampacity reference entry.
struct CDCKCableEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var conductorMaterial: String   // "Copper" / "Aluminum"
    var crossSectionMM2: Double      // conductor cross-section in mm²
    var ampacityA: Double            // rated current carrying capacity in amperes
    var insulationTemp: Int          // insulation rating in °C (e.g. 70, 90)
    var installationMethod: String   // e.g. "Conduit", "Free air"
    var isFavorite: Bool

    init(id: UUID = UUID(),
         conductorMaterial: String,
         crossSectionMM2: Double,
         ampacityA: Double,
         insulationTemp: Int,
         installationMethod: String,
         isFavorite: Bool = false) {
        self.id = id
        self.conductorMaterial = conductorMaterial
        self.crossSectionMM2 = crossSectionMM2
        self.ampacityA = ampacityA
        self.insulationTemp = insulationTemp
        self.installationMethod = installationMethod
        self.isFavorite = isFavorite
    }
}
