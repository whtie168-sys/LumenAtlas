//
//  CDCKMotorParamView.swift
//  TechRefPro
//
//  Standard three-phase motor parameter reference table.
//

import SwiftUI

struct CDCKMotorParamView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var query = ""

    private var filtered: [CDCKMotorParam] {
        guard !query.isEmpty else { return store.motors }
        return store.motors.filter {
            "\($0.powerKW)".contains(query)
                || "\($0.powerHP)".contains(query)
                || "\(Int($0.fullLoadAmpsA))".contains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CDCKSearchBar(text: $query, placeholder: "Search kW / HP / FLA")

                if filtered.isEmpty {
                    CDCKEmptyState(systemImage: "magnifyingglass",
                                   title: "No matches",
                                   message: "Try another rating.")
                } else {
                    ForEach(filtered) { m in
                        CDCKCardView {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("\(CDCKFormatHelper.smart(m.powerKW)) kW")
                                        .font(.system(size: 17, weight: .bold, design: .monospaced))
                                        .foregroundColor(CDCKTheme.amber)
                                    Text("≈ \(CDCKFormatHelper.smart(m.powerHP)) HP")
                                        .font(.system(size: 12))
                                        .foregroundColor(CDCKTheme.textSecondary)
                                    Spacer()
                                    CDCKFavoriteButton(isOn: store.isFavorite(.motor, m.id)) {
                                        store.toggleFavorite(.motor, m.id)
                                    }
                                }
                                Divider().background(CDCKTheme.cardStroke)
                                CDCKValueRow(label: "Full-load current", value: "\(CDCKFormatHelper.smart(m.fullLoadAmpsA)) A @ \(m.voltageV) V")
                                CDCKValueRow(label: "Efficiency (η)", value: "\(Int(m.efficiency * 100)) %")
                                CDCKValueRow(label: "Power factor", value: CDCKFormatHelper.smart(m.powerFactor))
                                CDCKValueRow(label: "Poles", value: "\(m.poles)")
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Motor Parameters", displayMode: .inline)
    }
}
