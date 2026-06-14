//
//  CDCKSettingsView.swift
//  TechRefPro
//
//  About / settings screen. Offers data reset and app information.
//

import SwiftUI

struct CDCKSettingsView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var showResetConfirm = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    appHeader

                    CDCKCardView {
                        VStack(alignment: .leading, spacing: 14) {
                            CDCKSectionHeader(title: "Library", systemImage: "books.vertical")
                            CDCKValueRow(label: "Cable entries", value: "\(store.cables.count)", mono: true)
                            CDCKValueRow(label: "Wire gauges", value: "\(store.wireGauges.count)", mono: true)
                            CDCKValueRow(label: "Breaker ratings", value: "\(store.breakers.count)", mono: true)
                            CDCKValueRow(label: "Motor entries", value: "\(store.motors.count)", mono: true)
                            CDCKValueRow(label: "Safety topics", value: "\(store.safety.count)", mono: true)
                            CDCKValueRow(label: "Favorites", value: "\(store.totalFavoriteCount)", mono: true)
                            CDCKValueRow(label: "History records", value: "\(store.history.count)", mono: true)
                        }
                    }
                    .padding(.horizontal, 16)

                    CDCKCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            CDCKSectionHeader(title: "Data", systemImage: "externaldrive")
                            Text("All data is stored on this device only. There is no account, no network access and no tracking.")
                                .font(.system(size: 13))
                                .foregroundColor(CDCKTheme.textSecondary)
                            Button {
                                showResetConfirm = true
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("Reset to defaults")
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(hex: 0xFF453A))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(RoundedRectangle(cornerRadius: 12).stroke(Color(hex: 0xFF453A).opacity(0.5), lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)

                    CDCKCardView {
                        VStack(alignment: .leading, spacing: 12) {
                            CDCKSectionHeader(title: "About", systemImage: "info.circle")
                            CDCKValueRow(label: "Version", value: appVersion, mono: true)
                            Text("TechRef Pro is an offline field reference for electricians and electrical technicians. Values are typical engineering figures intended as a quick on-site guide — always verify against local codes and equipment ratings.")
                                .font(.system(size: 12))
                                .foregroundColor(CDCKTheme.textTertiary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
                .padding(.top, 8)
            }
            .cdckScreenBackground()
            .navigationBarTitle("Settings", displayMode: .large)
            .actionSheet(isPresented: $showResetConfirm) {
                ActionSheet(title: Text("Reset all data?"),
                            message: Text("This restores the bundled reference data and clears favorites and history."),
                            buttons: [
                                .destructive(Text("Reset")) {
                                    store.resetToDefaults()
                                    CDCKHapticHelper.warning()
                                },
                                .cancel()
                            ])
            }
        }
        .navigationViewStyle(.stack)
    }

    private var appHeader: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(CDCKTheme.accent.opacity(0.18))
                    .frame(width: 72, height: 72)
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundColor(CDCKTheme.accent)
            }
            Text("TechRef Pro")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(CDCKTheme.textPrimary)
            Text("Electrical Field Reference")
                .font(.system(size: 13))
                .foregroundColor(CDCKTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
}
