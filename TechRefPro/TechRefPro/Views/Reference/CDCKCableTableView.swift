//
//  CDCKCableTableView.swift
//  TechRefPro
//
//  Searchable, favoritable cable ampacity reference table.
//

import SwiftUI

struct CDCKCableTableView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var query = ""
    @State private var materialFilter: String = "All"

    private var materials: [String] {
        ["All"] + Array(Set(store.cables.map { $0.conductorMaterial })).sorted()
    }

    private var filtered: [CDCKCableEntry] {
        store.cables.filter { entry in
            let matchesMaterial = materialFilter == "All" || entry.conductorMaterial == materialFilter
            let matchesQuery = query.isEmpty
                || entry.conductorMaterial.localizedCaseInsensitiveContains(query)
                || "\(entry.crossSectionMM2)".contains(query)
                || "\(Int(entry.ampacityA))".contains(query)
            return matchesMaterial && matchesQuery
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CDCKSearchBar(text: $query, placeholder: "Search size or ampacity")
                Picker("Material", selection: $materialFilter) {
                    ForEach(materials, id: \.self) { Text($0).tag($0) }
                }
                .pickerStyle(.segmented)

                if filtered.isEmpty {
                    CDCKEmptyState(systemImage: "magnifyingglass",
                                   title: "No matches",
                                   message: "Try a different size or material.")
                } else {
                    ForEach(filtered) { entry in
                        CDCKCableRow(entry: entry,
                                     isFavorite: store.isFavorite(.cable, entry.id)) {
                            store.toggleFavorite(.cable, entry.id)
                        }
                    }
                }
            }
            .padding(16)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Cable Ampacity", displayMode: .inline)
    }
}

struct CDCKCableRow: View {
    let entry: CDCKCableEntry
    let isFavorite: Bool
    let onToggle: () -> Void

    var body: some View {
        CDCKCardView {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("\(CDCKFormatHelper.smart(entry.crossSectionMM2)) mm²")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(CDCKTheme.textPrimary)
                        Text(entry.conductorMaterial)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(CDCKTheme.textSecondary)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(CDCKTheme.accent.opacity(0.18)))
                    }
                    Text("\(entry.insulationTemp)°C · \(entry.installationMethod)")
                        .font(.system(size: 12))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(Int(entry.ampacityA)) A")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(CDCKTheme.accent)
                    Text("ampacity")
                        .font(.system(size: 10))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                CDCKFavoriteButton(isOn: isFavorite, action: onToggle)
            }
        }
    }
}
