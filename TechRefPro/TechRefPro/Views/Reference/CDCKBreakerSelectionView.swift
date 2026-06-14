//
//  CDCKBreakerSelectionView.swift
//  TechRefPro
//
//  Circuit breaker / contactor selection reference.
//

import SwiftUI

struct CDCKBreakerSelectionView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var query = ""

    private var filtered: [CDCKBreakerSpec] {
        guard !query.isEmpty else { return store.breakers }
        return store.breakers.filter {
            "\($0.ratedCurrentA)".contains(query)
                || $0.curveType.localizedCaseInsensitiveContains(query)
                || $0.typicalUse.localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CDCKSearchBar(text: $query, placeholder: "Search rating or use")

                if filtered.isEmpty {
                    CDCKEmptyState(systemImage: "magnifyingglass",
                                   title: "No matches",
                                   message: "Try another rating.")
                } else {
                    ForEach(filtered) { spec in
                        CDCKCardView {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Text("\(spec.ratedCurrentA) A")
                                            .font(.system(size: 17, weight: .bold, design: .monospaced))
                                            .foregroundColor(CDCKTheme.green)
                                        Text("\(spec.poles)P")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(CDCKTheme.textSecondary)
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Capsule().fill(CDCKTheme.green.opacity(0.18)))
                                        Text("Curve \(spec.curveType)")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundColor(CDCKTheme.textSecondary)
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Capsule().fill(CDCKTheme.accent.opacity(0.18)))
                                    }
                                    Text(spec.typicalUse)
                                        .font(.system(size: 13))
                                        .foregroundColor(CDCKTheme.textTertiary)
                                    Text("Breaking capacity \(CDCKFormatHelper.smart(spec.breakingCapacityKA)) kA")
                                        .font(.system(size: 11))
                                        .foregroundColor(CDCKTheme.textTertiary)
                                }
                                Spacer()
                                CDCKFavoriteButton(isOn: store.isFavorite(.breaker, spec.id)) {
                                    store.toggleFavorite(.breaker, spec.id)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Breaker Selection", displayMode: .inline)
    }
}
