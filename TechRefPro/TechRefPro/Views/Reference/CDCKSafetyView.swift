//
//  CDCKSafetyView.swift
//  TechRefPro
//
//  Safety standards reference, grouped by category and searchable.
//

import SwiftUI

struct CDCKSafetyView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var query = ""

    private var filtered: [CDCKSafetyStandard] {
        guard !query.isEmpty else { return store.safety }
        return store.safety.filter {
            $0.title.localizedCaseInsensitiveContains(query)
                || $0.content.localizedCaseInsensitiveContains(query)
                || $0.category.localizedCaseInsensitiveContains(query)
        }
    }

    private var grouped: [(category: String, items: [CDCKSafetyStandard])] {
        let dict = Dictionary(grouping: filtered) { $0.category }
        return dict.keys.sorted().map { ($0, dict[$0] ?? []) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                CDCKSearchBar(text: $query, placeholder: "Search safety topics")

                if filtered.isEmpty {
                    CDCKEmptyState(systemImage: "magnifyingglass",
                                   title: "No matches",
                                   message: "Try a different keyword.")
                } else {
                    ForEach(grouped, id: \.category) { group in
                        VStack(alignment: .leading, spacing: 10) {
                            CDCKSectionHeader(title: group.category, systemImage: "shield.lefthalf.filled")
                            ForEach(group.items) { item in
                                CDCKSafetyRow(item: item,
                                              isFavorite: store.isFavorite(.safety, item.id)) {
                                    store.toggleFavorite(.safety, item.id)
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Safety Standards", displayMode: .inline)
    }
}

struct CDCKSafetyRow: View {
    let item: CDCKSafetyStandard
    let isFavorite: Bool
    let onToggle: () -> Void

    var body: some View {
        CDCKCardView {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(CDCKTheme.textPrimary)
                    Spacer()
                    CDCKFavoriteButton(isOn: isFavorite, action: onToggle)
                }
                Text(item.content)
                    .font(.system(size: 13))
                    .foregroundColor(CDCKTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
