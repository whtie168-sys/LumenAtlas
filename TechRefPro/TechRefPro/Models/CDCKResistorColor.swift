//
//  CDCKResistorColor.swift
//  TechRefPro
//
//  Resistor color-band decoding model and engine.
//

import SwiftUI

/// A standard resistor color band with its digit / multiplier / tolerance role.
struct CDCKResistorBand: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
    /// Significant-figure digit (nil for none, e.g. gold/silver).
    let digit: Int?
    /// Power-of-ten multiplier exponent.
    let multiplier: Int
    /// Tolerance in percent (nil if the color is not a tolerance color).
    let tolerance: Double?

    static let all: [CDCKResistorBand] = [
        CDCKResistorBand(name: "Black",  color: Color(hex: 0x000000), digit: 0, multiplier: 0,  tolerance: nil),
        CDCKResistorBand(name: "Brown",  color: Color(hex: 0x7B3F00), digit: 1, multiplier: 1,  tolerance: 1),
        CDCKResistorBand(name: "Red",    color: Color(hex: 0xD0021B), digit: 2, multiplier: 2,  tolerance: 2),
        CDCKResistorBand(name: "Orange", color: Color(hex: 0xF5A623), digit: 3, multiplier: 3,  tolerance: nil),
        CDCKResistorBand(name: "Yellow", color: Color(hex: 0xF8E71C), digit: 4, multiplier: 4,  tolerance: nil),
        CDCKResistorBand(name: "Green",  color: Color(hex: 0x2EA84F), digit: 5, multiplier: 5,  tolerance: 0.5),
        CDCKResistorBand(name: "Blue",   color: Color(hex: 0x2D6BD0), digit: 6, multiplier: 6,  tolerance: 0.25),
        CDCKResistorBand(name: "Violet", color: Color(hex: 0x8B5CF6), digit: 7, multiplier: 7,  tolerance: 0.1),
        CDCKResistorBand(name: "Grey",   color: Color(hex: 0x9B9B9B), digit: 8, multiplier: 8,  tolerance: 0.05),
        CDCKResistorBand(name: "White",  color: Color(hex: 0xFFFFFF), digit: 9, multiplier: 9,  tolerance: nil),
        CDCKResistorBand(name: "Gold",   color: Color(hex: 0xD4AF37), digit: nil, multiplier: -1, tolerance: 5),
        CDCKResistorBand(name: "Silver", color: Color(hex: 0xC0C0C0), digit: nil, multiplier: -2, tolerance: 10)
    ]

    /// Bands valid for a digit position (exclude gold/silver).
    static var digitBands: [CDCKResistorBand] { all.filter { $0.digit != nil } }
    /// Bands valid as a multiplier (gold/silver allowed).
    static var multiplierBands: [CDCKResistorBand] { all }
    /// Bands valid as tolerance.
    static var toleranceBands: [CDCKResistorBand] { all.filter { $0.tolerance != nil } }
}

/// Decodes resistor color bands into an ohm value + tolerance.
enum CDCKResistorEngine {

    /// Decodes a 4-band resistor.
    /// - Returns: (ohms, tolerancePercent)
    static func decode(band1: CDCKResistorBand,
                       band2: CDCKResistorBand,
                       multiplier: CDCKResistorBand,
                       tolerance: CDCKResistorBand) -> (ohms: Double, tolerance: Double) {
        let d1 = band1.digit ?? 0
        let d2 = band2.digit ?? 0
        let significant = Double(d1 * 10 + d2)
        let ohms = significant * pow(10.0, Double(multiplier.multiplier))
        return (ohms, tolerance.tolerance ?? 0)
    }

    /// Human-readable ohm formatting with Ω / kΩ / MΩ.
    static func formatOhms(_ ohms: Double) -> String {
        if ohms >= 1_000_000 {
            return "\(CDCKFormatHelper.smart(ohms / 1_000_000)) MΩ"
        } else if ohms >= 1_000 {
            return "\(CDCKFormatHelper.smart(ohms / 1_000)) kΩ"
        } else {
            return "\(CDCKFormatHelper.smart(ohms)) Ω"
        }
    }
}
