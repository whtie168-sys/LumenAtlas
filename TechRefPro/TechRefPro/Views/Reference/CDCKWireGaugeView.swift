//
//  CDCKWireGaugeView.swift
//  TechRefPro
//
//  AWG ↔ mm² ↔ ampacity cross-reference table.
//

import SwiftUI

struct CDCKWireGaugeView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var query = ""

    private var filtered: [CDCKWireGauge] {
        guard !query.isEmpty else { return store.wireGauges }
        return store.wireGauges.filter {
            $0.awg.localizedCaseInsensitiveContains(query)
                || "\($0.mm2)".contains(query)
                || "\(Int($0.maxAmps))".contains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CDCKSearchBar(text: $query, placeholder: "Search AWG or mm²")

                // Column header.
                HStack {
                    Text("AWG").frame(width: 60, alignment: .leading)
                    Text("mm²").frame(maxWidth: .infinity, alignment: .leading)
                    Text("Max A").frame(width: 70, alignment: .trailing)
                    Spacer().frame(width: 28)
                }
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(CDCKTheme.textTertiary)
                .padding(.horizontal, 16)

                if filtered.isEmpty {
                    CDCKEmptyState(systemImage: "magnifyingglass",
                                   title: "No matches",
                                   message: "Try another gauge.")
                } else {
                    ForEach(filtered) { g in
                        CDCKCardView(padding: 14) {
                            HStack {
                                Text(g.awg)
                                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                                    .foregroundColor(CDCKTheme.cyan)
                                    .frame(width: 60, alignment: .leading)
                                Text(CDCKFormatHelper.smart(g.mm2))
                                    .font(.system(size: 15, design: .monospaced))
                                    .foregroundColor(CDCKTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text("\(Int(g.maxAmps)) A")
                                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                    .foregroundColor(CDCKTheme.textSecondary)
                                    .frame(width: 70, alignment: .trailing)
                                CDCKFavoriteButton(isOn: store.isFavorite(.wireGauge, g.id)) {
                                    store.toggleFavorite(.wireGauge, g.id)
                                }
                                .frame(width: 28)
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Wire Gauge", displayMode: .inline)
    }
}
