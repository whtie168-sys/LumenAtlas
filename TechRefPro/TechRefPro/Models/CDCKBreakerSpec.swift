//
//  CDCKBreakerSpec.swift
//  TechRefPro
//
//  Circuit breaker / contactor selection reference entry.
//

import Foundation

/// A circuit breaker rating reference entry used for selection guidance.
struct CDCKBreakerSpec: Identifiable, Codable, Equatable {
    var id = UUID()
    var ratedCurrentA: Int        // nominal rated current (In) in amperes
    var poles: Int                // number of poles (1, 2, 3, 4)
    var curveType: String         // tripping curve, e.g. "B", "C", "D"
    var breakingCapacityKA: Double // short-circuit breaking capacity in kA
    var typicalUse: String        // suggested application
    var isFavorite: Bool

    init(id: UUID = UUID(),
         ratedCurrentA: Int,
         poles: Int,
         curveType: String,
         breakingCapacityKA: Double,
         typicalUse: String,
         isFavorite: Bool = false) {
        self.id = id
        self.ratedCurrentA = ratedCurrentA
        self.poles = poles
        self.curveType = curveType
        self.breakingCapacityKA = breakingCapacityKA
        self.typicalUse = typicalUse
        self.isFavorite = isFavorite
    }
}
