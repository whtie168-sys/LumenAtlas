//
//  CDCKReferenceLibraryView.swift
//  TechRefPro
//
//  Reference Library home: entry points into each reference dataset.
//

import SwiftUI

/// A descriptor for a reference category.
private struct CDCKRefCategory: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
}

/// Home screen for the Reference Library core feature.
struct CDCKReferenceLibraryView: View {
    @EnvironmentObject var store: CDCKDataStore

    private var categories: [CDCKRefCategory] {
        [
            CDCKRefCategory(id: "cable", title: "Cable Ampacity",
                            subtitle: "\(store.cables.count) entries · Cu / Al",
                            systemImage: "cable.connector", tint: CDCKTheme.accent),
            CDCKRefCategory(id: "wire", title: "Wire Gauge",
                            subtitle: "AWG 18 → 4/0 · \(store.wireGauges.count) sizes",
                            systemImage: "ruler", tint: CDCKTheme.cyan),
            CDCKRefCategory(id: "breaker", title: "Breaker Selection",
                            subtitle: "\(store.breakers.count) ratings",
                            systemImage: "switch.2", tint: CDCKTheme.green),
            CDCKRefCategory(id: "motor", title: "Motor Parameters",
                            subtitle: "\(store.motors.count) standard motors",
                            systemImage: "gearshape.2", tint: CDCKTheme.amber),
            CDCKRefCategory(id: "safety", title: "Safety Standards",
                            subtitle: "\(store.safety.count) topics",
                            systemImage: "exclamationmark.shield", tint: Color(hex: 0xFF453A))
        ]
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(categories) { cat in
                        NavigationLink(destination: destination(for: cat.id)) {
                            CDCKRefCategoryRow(title: cat.title, subtitle: cat.subtitle,
                                               systemImage: cat.systemImage, tint: cat.tint)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .cdckScreenBackground()
            .navigationBarTitle("Reference", displayMode: .large)
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private func destination(for id: String) -> some View {
        switch id {
        case "cable":   CDCKCableTableView()
        case "wire":    CDCKWireGaugeView()
        case "breaker": CDCKBreakerSelectionView()
        case "motor":   CDCKMotorParamView()
        case "safety":  CDCKSafetyView()
        default:        EmptyView()
        }
    }
}

/// A category row used on the reference home.
private struct CDCKRefCategoryRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        CDCKCardView {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(tint.opacity(0.18))
                        .frame(width: 46, height: 46)
                    Image(systemName: systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(tint)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CDCKTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(CDCKTheme.textTertiary)
            }
        }
    }
}
