//
//  CDCKWireGauge.swift
//  TechRefPro
//
//  AWG to metric cross-section / ampacity mapping.
//

import Foundation

/// A wire gauge cross-reference entry (AWG ↔ mm² ↔ max amps).
struct CDCKWireGauge: Identifiable, Codable, Equatable {
    var id = UUID()
    var awg: String        // American Wire Gauge designation, e.g. "12", "1/0"
    var mm2: Double         // equivalent cross-section in mm²
    var maxAmps: Double     // typical maximum current in amperes
    var isFavorite: Bool

    init(id: UUID = UUID(),
         awg: String,
         mm2: Double,
         maxAmps: Double,
         isFavorite: Bool = false) {
        self.id = id
        self.awg = awg
        self.mm2 = mm2
        self.maxAmps = maxAmps
        self.isFavorite = isFavorite
    }
}
