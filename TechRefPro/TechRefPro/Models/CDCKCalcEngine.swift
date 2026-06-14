//
//  CDCKCalcEngine.swift
//  TechRefPro
//
//  Pure calculation functions for the field calculators. Kept free of any
//  UI so the formulas can be reasoned about and reused independently.
//

import Foundation

/// Stateless electrical calculation engine.
enum CDCKCalcEngine {

    static let sqrt3 = 1.7320508075688772

    // MARK: Ohm's Law

    /// Voltage from current and resistance: V = I · R.
    static func voltage(current: Double, resistance: Double) -> Double {
        current * resistance
    }
    /// Current from voltage and resistance: I = V / R.
    static func current(voltage: Double, resistance: Double) -> Double {
        guard resistance != 0 else { return .nan }
        return voltage / resistance
    }
    /// Resistance from voltage and current: R = V / I.
    static func resistance(voltage: Double, current: Double) -> Double {
        guard current != 0 else { return .nan }
        return voltage / current
    }

    // MARK: Power

    /// DC power: P = V · I.
    static func powerDC(voltage: Double, current: Double) -> Double {
        voltage * current
    }
    /// Single-phase AC power: P = V · I · PF.
    static func powerSinglePhase(voltage: Double, current: Double, pf: Double) -> Double {
        voltage * current * pf
    }
    /// Three-phase AC power: P = √3 · V · I · PF (V = line voltage).
    static func powerThreePhase(voltage: Double, current: Double, pf: Double) -> Double {
        sqrt3 * voltage * current * pf
    }

    // MARK: Voltage drop
    // resistancePerKm is the conductor loop resistance in Ω/km, length in metres.

    /// Single-phase voltage drop: ΔU = 2 · I · L · Rₖ / 1000.
    static func voltageDropSinglePhase(current: Double, lengthM: Double, resistancePerKm: Double) -> Double {
        2.0 * current * lengthM * resistancePerKm / 1000.0
    }
    /// Three-phase voltage drop: ΔU = √3 · I · L · Rₖ / 1000.
    static func voltageDropThreePhase(current: Double, lengthM: Double, resistancePerKm: Double) -> Double {
        sqrt3 * current * lengthM * resistancePerKm / 1000.0
    }

    // MARK: Motor full-load current

    /// Three-phase motor current: I = P / (√3 · V · PF · η).
    /// `powerW` in watts, `voltage` line-to-line, efficiency & pf in 0–1.
    static func motorCurrentThreePhase(powerW: Double, voltage: Double, pf: Double, efficiency: Double) -> Double {
        let denom = sqrt3 * voltage * pf * efficiency
        guard denom != 0 else { return .nan }
        return powerW / denom
    }
}
