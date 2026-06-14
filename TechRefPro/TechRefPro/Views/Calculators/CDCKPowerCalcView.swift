//
//  CDCKPowerCalcView.swift
//  TechRefPro
//
//  Power calculator: DC, single-phase and three-phase AC.
//

import SwiftUI

struct CDCKPowerCalcView: View {
    @EnvironmentObject var store: CDCKDataStore

    private enum Mode: Hashable { case dc, single, three }
    @State private var mode: Mode = .single

    @State private var voltage = ""
    @State private var current = ""
    @State private var pf = "0.85"

    @State private var result: Double?

    private let toolID = "power"

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                CDCKCardView {
                    VStack(alignment: .leading, spacing: 14) {
                        CDCKSegmented(title: "Supply type",
                                      selection: $mode,
                                      options: [("DC", .dc),
                                                ("1-Phase", .single),
                                                ("3-Phase", .three)])
                            .onChange(of: mode) { _ in result = nil }

                        CDCKInputField(title: mode == .three ? "Line Voltage (V)" : "Voltage (V)",
                                       unit: "V", text: $voltage)
                        CDCKInputField(title: "Current (I)", unit: "A", text: $current)
                        if mode != .dc {
                            CDCKInputField(title: "Power Factor (PF)", unit: "", placeholder: "0.85", text: $pf)
                        }
                    }
                }
                .padding(.horizontal, 16)

                CDCKPrimaryButton(title: "Calculate", systemImage: "equal.circle") {
                    calculate()
                }
                .padding(.horizontal, 16)

                if let result = result {
                    CDCKResultCard(title: "Active Power",
                                   value: CDCKFormatHelper.smart(result),
                                   unit: "W",
                                   note: result >= 1000 ? "≈ \(CDCKFormatHelper.smart(result / 1000)) kW" : nil)
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 12)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Power", displayMode: .inline)
        .toolbar { favoriteToolbarItem(store: store, toolID: toolID) }
    }

    private func calculate() {
        let v = Double(voltage) ?? 0
        let i = Double(current) ?? 0
        let factor = Double(pf) ?? 0.85
        let value: Double
        var inputs: [String: Double] = ["V": v, "I": i]
        switch mode {
        case .dc:
            value = CDCKCalcEngine.powerDC(voltage: v, current: i)
        case .single:
            value = CDCKCalcEngine.powerSinglePhase(voltage: v, current: i, pf: factor)
            inputs["PF"] = factor
        case .three:
            value = CDCKCalcEngine.powerThreePhase(voltage: v, current: i, pf: factor)
            inputs["PF"] = factor
        }
        guard value.isFinite else { CDCKHapticHelper.warning(); result = nil; return }
        result = value
        CDCKHapticHelper.success()
        let name = mode == .dc ? "Power (DC)" : (mode == .single ? "Power (1-φ)" : "Power (3-φ)")
        store.addHistory(CDCKCalculationHistory(formulaName: name, inputs: inputs, result: value, resultUnit: "W"))
    }
}
