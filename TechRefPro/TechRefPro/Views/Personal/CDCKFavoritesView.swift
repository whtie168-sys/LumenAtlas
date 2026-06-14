//
//  CDCKFavoritesView.swift
//  TechRefPro
//
//  Aggregated favorites across all reference categories and calculators.
//

import SwiftUI

struct CDCKFavoritesView: View {
    @EnvironmentObject var store: CDCKDataStore

    private var favoriteTools: [CDCKCalculatorTool] {
        CDCKCalculatorCatalog.tools.filter { store.isFavoriteFormula($0.id) }
    }

    private var hasAny: Bool { store.totalFavoriteCount > 0 }

    var body: some View {
        NavigationView {
            Group {
                if !hasAny {
                    ScrollView {
                        CDCKEmptyState(systemImage: "star",
                                       title: "No favorites yet",
                                       message: "Tap the star on any calculator or reference entry to pin it here.")
                            .padding(.top, 60)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if !favoriteTools.isEmpty {
                                section("Calculators", icon: "function") {
                                    ForEach(favoriteTools) { tool in
                                        NavigationLink(destination: toolDestination(tool)) {
                                            favoriteLineRow(icon: tool.systemImage,
                                                            tint: tool.tint,
                                                            title: tool.title,
                                                            subtitle: tool.subtitle)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            cableSection
                            wireSection
                            breakerSection
                            motorSection
                            safetySection
                        }
                        .padding(16)
                    }
                }
            }
            .cdckScreenBackground()
            .navigationBarTitle("Favorites", displayMode: .large)
        }
        .navigationViewStyle(.stack)
    }

    // MARK: Sections

    @ViewBuilder private var cableSection: some View {
        let items = store.favoriteCables()
        if !items.isEmpty {
            section("Cable Ampacity", icon: "cable.connector") {
                ForEach(items) { entry in
                    CDCKCableRow(entry: entry, isFavorite: true) {
                        store.toggleFavorite(.cable, entry.id)
                    }
                }
            }
        }
    }

    @ViewBuilder private var wireSection: some View {
        let items = store.favoriteWireGauges()
        if !items.isEmpty {
            section("Wire Gauge", icon: "ruler") {
                ForEach(items) { g in
                    favoriteLineRow(icon: "ruler", tint: CDCKTheme.cyan,
                                    title: "AWG \(g.awg)",
                                    subtitle: "\(CDCKFormatHelper.smart(g.mm2)) mm² · \(Int(g.maxAmps)) A") {
                        store.toggleFavorite(.wireGauge, g.id)
                    }
                }
            }
        }
    }

    @ViewBuilder private var breakerSection: some View {
        let items = store.favoriteBreakers()
        if !items.isEmpty {
            section("Breakers", icon: "switch.2") {
                ForEach(items) { spec in
                    favoriteLineRow(icon: "switch.2", tint: CDCKTheme.green,
                                    title: "\(spec.ratedCurrentA) A · \(spec.poles)P · Curve \(spec.curveType)",
                                    subtitle: spec.typicalUse) {
                        store.toggleFavorite(.breaker, spec.id)
                    }
                }
            }
        }
    }

    @ViewBuilder private var motorSection: some View {
        let items = store.favoriteMotors()
        if !items.isEmpty {
            section("Motors", icon: "gearshape.2") {
                ForEach(items) { m in
                    favoriteLineRow(icon: "gearshape.2", tint: CDCKTheme.amber,
                                    title: "\(CDCKFormatHelper.smart(m.powerKW)) kW",
                                    subtitle: "\(CDCKFormatHelper.smart(m.fullLoadAmpsA)) A @ \(m.voltageV) V") {
                        store.toggleFavorite(.motor, m.id)
                    }
                }
            }
        }
    }

    @ViewBuilder private var safetySection: some View {
        let items = store.favoriteSafety()
        if !items.isEmpty {
            section("Safety", icon: "exclamationmark.shield") {
                ForEach(items) { item in
                    CDCKSafetyRow(item: item, isFavorite: true) {
                        store.toggleFavorite(.safety, item.id)
                    }
                }
            }
        }
    }

    // MARK: Helpers

    private func section<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            CDCKSectionHeader(title: title, systemImage: icon)
            content()
        }
    }

    private func favoriteLineRow(icon: String, tint: Color, title: String, subtitle: String,
                                 onRemove: (() -> Void)? = nil) -> some View {
        CDCKCardView {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tint)
                    .frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(CDCKTheme.textPrimary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                Spacer()
                if let onRemove = onRemove {
                    CDCKFavoriteButton(isOn: true, action: onRemove)
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
            }
        }
    }

    @ViewBuilder
    private func toolDestination(_ tool: CDCKCalculatorTool) -> some View {
        switch tool.id {
        case "ohm":      CDCKOhmLawView()
        case "power":    CDCKPowerCalcView()
        case "vdrop":    CDCKVoltageDropView()
        case "motor":    CDCKMotorCurrentView()
        case "resistor": CDCKResistorDecoderView()
        default:         EmptyView()
        }
    }
}
