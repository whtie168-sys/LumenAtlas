//
//  CDCKCalculatorCatalog.swift
//  TechRefPro
//
//  Static catalog describing the available calculators. Drives the
//  calculator home grid and the calculator-favorites feature.
//

import SwiftUI

/// A descriptor for one calculator tool.
struct CDCKCalculatorTool: Identifiable {
    let id: String          // stable id for favoriting
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
}

/// The catalog of field calculators.
enum CDCKCalculatorCatalog {
    static let tools: [CDCKCalculatorTool] = [
        CDCKCalculatorTool(id: "ohm",
                           title: "Ohm's Law",
                           subtitle: "V · I · R",
                           systemImage: "bolt.circle",
                           tint: CDCKTheme.accent),
        CDCKCalculatorTool(id: "power",
                           title: "Power",
                           subtitle: "DC · 1-φ · 3-φ",
                           systemImage: "powerplug",
                           tint: CDCKTheme.cyan),
        CDCKCalculatorTool(id: "vdrop",
                           title: "Voltage Drop",
                           subtitle: "Cable run loss",
                           systemImage: "arrow.down.right.circle",
                           tint: CDCKTheme.green),
        CDCKCalculatorTool(id: "motor",
                           title: "Motor Current",
                           subtitle: "3-φ full load",
                           systemImage: "gearshape.2",
                           tint: CDCKTheme.amber),
        CDCKCalculatorTool(id: "resistor",
                           title: "Resistor Decoder",
                           subtitle: "Color bands",
                           systemImage: "circle.hexagongrid",
                           tint: Color(hex: 0xFF453A))
    ]

    static func tool(id: String) -> CDCKCalculatorTool? {
        tools.first { $0.id == id }
    }
}
