//
//  CDCKOhmLawView.swift
//  TechRefPro
//
//  Ohm's Law calculator: solve for V, I, or R from the other two.
//

import SwiftUI

struct CDCKOhmLawView: View {
    @EnvironmentObject var store: CDCKDataStore

    /// Which quantity is being solved for.
    private enum Solve: Hashable { case voltage, current, resistance }
    @State private var solve: Solve = .voltage

    @State private var voltage = ""
    @State private var current = ""
    @State private var resistance = ""

    @State private var result: Double?

    private let toolID = "ohm"

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                CDCKCardView {
                    VStack(alignment: .leading, spacing: 14) {
                        CDCKSegmented(title: "Solve for",
                                      selection: $solve,
                                      options: [("Voltage", .voltage),
                                                ("Current", .current),
                                                ("Resistance", .resistance)])
                            .onChange(of: solve) { _ in result = nil }

                        inputs
                    }
                }
                .padding(.horizontal, 16)

                CDCKPrimaryButton(title: "Calculate", systemImage: "equal.circle") {
                    calculate()
                }
                .padding(.horizontal, 16)

                if let result = result {
                    resultCard(result)
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 12)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Ohm's Law", displayMode: .inline)
        .toolbar { favoriteToolbarItem(store: store, toolID: toolID) }
    }

    @ViewBuilder
    private var inputs: some View {
        switch solve {
        case .voltage:
            CDCKInputField(title: "Current (I)", unit: "A", text: $current)
            CDCKInputField(title: "Resistance (R)", unit: "Ω", text: $resistance)
        case .current:
            CDCKInputField(title: "Voltage (V)", unit: "V", text: $voltage)
            CDCKInputField(title: "Resistance (R)", unit: "Ω", text: $resistance)
        case .resistance:
            CDCKInputField(title: "Voltage (V)", unit: "V", text: $voltage)
            CDCKInputField(title: "Current (I)", unit: "A", text: $current)
        }
    }

    private func resultCard(_ value: Double) -> some View {
        let (label, unit): (String, String)
        switch solve {
        case .voltage:    (label, unit) = ("Voltage", "V")
        case .current:    (label, unit) = ("Current", "A")
        case .resistance: (label, unit) = ("Resistance", "Ω")
        }
        return CDCKResultCard(title: label,
                              value: CDCKFormatHelper.smart(value),
                              unit: unit)
    }

    private func calculate() {
        let v = Double(voltage) ?? 0
        let i = Double(current) ?? 0
        let r = Double(resistance) ?? 0
        let value: Double
        var inputs: [String: Double] = [:]
        switch solve {
        case .voltage:
            value = CDCKCalcEngine.voltage(current: i, resistance: r)
            inputs = ["I": i, "R": r]
        case .current:
            value = CDCKCalcEngine.current(voltage: v, resistance: r)
            inputs = ["V": v, "R": r]
        case .resistance:
            value = CDCKCalcEngine.resistance(voltage: v, current: i)
            inputs = ["V": v, "I": i]
        }
        guard value.isFinite else {
            CDCKHapticHelper.warning()
            result = nil
            return
        }
        result = value
        CDCKHapticHelper.success()
        let unit = solve == .voltage ? "V" : (solve == .current ? "A" : "Ω")
        store.addHistory(CDCKCalculationHistory(formulaName: "Ohm's Law",
                                                inputs: inputs,
                                                result: value,
                                                resultUnit: unit))
    }
}
