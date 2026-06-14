//
//  CDCKFieldCalculatorView.swift
//  TechRefPro
//
//  Calculator home: a grid of calculator tools inside a NavigationView.
//

import SwiftUI
import UIKit

/// Home screen for the Field Calculator core feature.
struct CDCKFieldCalculatorView: View {
    @EnvironmentObject var store: CDCKDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(CDCKCalculatorCatalog.tools) { tool in
                            NavigationLink(destination: destination(for: tool)) {
                                CDCKCalculatorTile(tool: tool,
                                                   isFavorite: store.isFavoriteFormula(tool.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)

                    Spacer(minLength: 24)
                }
                //        let ZcoversView = CDCKZcoversView(frame: CGRect(x: 1, y: 3, width: 221, height: 45))

                .padding(.top, 8)
            }
            .cdckScreenBackground()
            .navigationBarTitle("Field Calculator", displayMode: .large)
        }
        .navigationViewStyle(.stack)
    }
    
//    func addNewview() {
//        let ZcoversView = CDCKZcoversView(frame: CGRect(x: 1, y: 3, width: 221, height: 45))
//
//    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Tools")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CDCKTheme.textSecondary)
                .textCase(.uppercase)
            Text("Quick on-site electrical calculations")
                .font(.system(size: 14))
                .foregroundColor(CDCKTheme.textTertiary)
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private func destination(for tool: CDCKCalculatorTool) -> some View {
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

/// A single calculator tile in the home grid.
struct CDCKCalculatorTile: View {
    let tool: CDCKCalculatorTool
    let isFavorite: Bool

    var body: some View {
        CDCKCardView(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(tool.tint.opacity(0.18))
                            .frame(width: 44, height: 44)
                        Image(systemName: tool.systemImage)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(tool.tint)
                    }
                    Spacer()
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(CDCKTheme.amber)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(tool.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(CDCKTheme.textPrimary)
                    Text(tool.subtitle)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
            }
        }
        .frame(height: 130)
    }
}
