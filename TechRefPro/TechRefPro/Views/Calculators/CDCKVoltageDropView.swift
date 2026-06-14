//
//  CDCKVoltageDropView.swift
//  TechRefPro
//
//  Voltage drop calculator for single- and three-phase cable runs.
//

import SwiftUI

struct CDCKVoltageDropView: View {
    @EnvironmentObject var store: CDCKDataStore

    private enum Phase: Hashable { case single, three }
    @State private var phase: Phase = .three

    @State private var current = ""
    @State private var length = ""
    @State private var resistancePerKm = ""
    @State private var sourceVoltage = "400"

    @State private var drop: Double?
    @State private var percent: Double?

    private let toolID = "vdrop"

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                CDCKCardView {
                    VStack(alignment: .leading, spacing: 14) {
                        CDCKSegmented(title: "System",
                                      selection: $phase,
                                      options: [("1-Phase", .single), ("3-Phase", .three)])
                            .onChange(of: phase) { _ in drop = nil; percent = nil }

                        CDCKInputField(title: "Current (I)", unit: "A", text: $current)
                        CDCKInputField(title: "Cable length (one-way)", unit: "m", text: $length)
                        CDCKInputField(title: "Conductor resistance", unit: "Ω/km", text: $resistancePerKm)
                        CDCKInputField(title: "Source voltage (for %)", unit: "V", placeholder: "400", text: $sourceVoltage)
                    }
                }
                .padding(.horizontal, 16)

                CDCKPrimaryButton(title: "Calculate", systemImage: "equal.circle") {
                    calculate()
                }
                .padding(.horizontal, 16)

                if let drop = drop {
                    CDCKResultCard(title: "Voltage Drop",
                                   value: CDCKFormatHelper.smart(drop),
                                   unit: "V",
                                   note: percent.map { "\(CDCKFormatHelper.fixed($0, 2)) % of source — \(($0 <= 5) ? "within 5% limit" : "exceeds 5% limit")" })
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 12)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Voltage Drop", displayMode: .inline)
        .toolbar { favoriteToolbarItem(store: store, toolID: toolID) }
    }

    private func calculate() {
        let i = Double(current) ?? 0
        let l = Double(length) ?? 0
        let r = Double(resistancePerKm) ?? 0
        let vSource = Double(sourceVoltage) ?? 0
        let value = phase == .single
            ? CDCKCalcEngine.voltageDropSinglePhase(current: i, lengthM: l, resistancePerKm: r)
            : CDCKCalcEngine.voltageDropThreePhase(current: i, lengthM: l, resistancePerKm: r)
        guard value.isFinite else { CDCKHapticHelper.warning(); drop = nil; return }
        drop = value
        percent = vSource > 0 ? (value / vSource * 100.0) : nil
        CDCKHapticHelper.success()
        store.addHistory(CDCKCalculationHistory(formulaName: phase == .single ? "Voltage Drop (1-φ)" : "Voltage Drop (3-φ)",
                                                inputs: ["I": i, "L": l, "R/km": r],
                                                result: value,
                                                resultUnit: "V"))
    }
}
