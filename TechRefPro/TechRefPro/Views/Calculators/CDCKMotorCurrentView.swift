//
//  CDCKMotorCurrentView.swift
//  TechRefPro
//
//  Three-phase induction motor full-load current estimator.
//

import SwiftUI

struct CDCKMotorCurrentView: View {
    @EnvironmentObject var store: CDCKDataStore

    @State private var power = ""
    private enum Unit: Hashable { case kw, hp }
    @State private var powerUnit: Unit = .kw

    @State private var voltage = "400"
    @State private var pf = "0.85"
    @State private var efficiency = "0.88"

    @State private var result: Double?

    private let toolID = "motor"

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                CDCKCardView {
                    VStack(alignment: .leading, spacing: 14) {
                        CDCKSegmented(title: "Rated power unit",
                                      selection: $powerUnit,
                                      options: [("kW", .kw), ("HP", .hp)])
                        CDCKInputField(title: "Rated power", unit: powerUnit == .kw ? "kW" : "HP", text: $power)
                        CDCKInputField(title: "Line voltage", unit: "V", placeholder: "400", text: $voltage)
                        CDCKInputField(title: "Power factor", unit: "", placeholder: "0.85", text: $pf)
                        CDCKInputField(title: "Efficiency (η)", unit: "", placeholder: "0.88", text: $efficiency)
                    }
                }
                .padding(.horizontal, 16)

                CDCKPrimaryButton(title: "Estimate Current", systemImage: "bolt.fill") {
                    calculate()
                }
                .padding(.horizontal, 16)

                if let result = result {
                    CDCKResultCard(title: "Full-Load Current",
                                   value: CDCKFormatHelper.smart(result),
                                   unit: "A",
                                   note: "Estimate for a 3-phase induction motor")
                        .padding(.horizontal, 16)
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 12)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Motor Current", displayMode: .inline)
        .toolbar { favoriteToolbarItem(store: store, toolID: toolID) }
    }

    private func calculate() {
        let p = Double(power) ?? 0
        // Convert HP to watts (1 HP ≈ 745.7 W), kW to watts.
        let powerW = powerUnit == .kw ? p * 1000.0 : p * 745.7
        let v = Double(voltage) ?? 0
        let factor = Double(pf) ?? 0.85
        let eta = Double(efficiency) ?? 0.88
        let value = CDCKCalcEngine.motorCurrentThreePhase(powerW: powerW, voltage: v, pf: factor, efficiency: eta)
        guard value.isFinite else { CDCKHapticHelper.warning(); result = nil; return }
        result = value
        CDCKHapticHelper.success()
        store.addHistory(CDCKCalculationHistory(formulaName: "Motor Current (3-φ)",
                                                inputs: ["P(W)": powerW, "V": v, "PF": factor, "η": eta],
                                                result: value,
                                                resultUnit: "A"))
    }
}
