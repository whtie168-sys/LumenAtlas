//
//  CDCKMotorParam.swift
//  TechRefPro
//
//  Standard three-phase induction motor parameter reference entry.
//

import Foundation

/// A reference entry for a standard squirrel-cage induction motor.
struct CDCKMotorParam: Identifiable, Codable, Equatable {
    var id = UUID()
    var powerKW: Double        // rated mechanical power in kW
    var powerHP: Double         // approximate equivalent in HP
    var voltageV: Int           // line voltage in volts (e.g. 400)
    var fullLoadAmpsA: Double   // full-load current in amperes
    var efficiency: Double      // efficiency (0–1)
    var powerFactor: Double     // power factor (0–1)
    var poles: Int              // number of poles
    var isFavorite: Bool

    init(id: UUID = UUID(),
         powerKW: Double,
         powerHP: Double,
         voltageV: Int,
         fullLoadAmpsA: Double,
         efficiency: Double,
         powerFactor: Double,
         poles: Int,
         isFavorite: Bool = false) {
        self.id = id
        self.powerKW = powerKW
        self.powerHP = powerHP
        self.voltageV = voltageV
        self.fullLoadAmpsA = fullLoadAmpsA
        self.efficiency = efficiency
        self.powerFactor = powerFactor
        self.poles = poles
        self.isFavorite = isFavorite
    }
}
