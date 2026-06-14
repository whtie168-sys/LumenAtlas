//
//  CDCKResultCard.swift
//  TechRefPro
//
//  Shared result display card and a toolbar favorite item for calculators.
//

import SwiftUI

/// A prominent result card showing a value and unit.
struct CDCKResultCard: View {
    let title: String
    let value: String
    var unit: String = ""
    var note: String? = nil

    var body: some View {
        CDCKCardView {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CDCKTheme.textSecondary)
                    .textCase(.uppercase)
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(value)
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
                        .foregroundColor(CDCKTheme.accent)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
                            .foregroundColor(CDCKTheme.textSecondary)
                    }
                }
                if let note = note {
                    Text(note)
                        .font(.system(size: 13))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
            }
        }
    }
}

/// A reusable toolbar favorite toggle for calculator screens.
@ToolbarContentBuilder
func favoriteToolbarItem(store: CDCKDataStore, toolID: String) -> some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
        CDCKFavoriteButton(isOn: store.isFavoriteFormula(toolID)) {
            store.toggleFavoriteFormula(toolID)
        }
    }
}
