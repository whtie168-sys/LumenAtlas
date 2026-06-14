//
//  CDCKResistorDecoderView.swift
//  TechRefPro
//
//  4-band resistor color decoder with a visual resistor preview.
//

import SwiftUI

struct CDCKResistorDecoderView: View {
    @EnvironmentObject var store: CDCKDataStore

    @State private var band1 = CDCKResistorBand.digitBands[1]   // Brown
    @State private var band2 = CDCKResistorBand.digitBands[0]   // Black
    @State private var multiplier = CDCKResistorBand.all[2]      // Red (×100)
    @State private var tolerance = CDCKResistorBand.all[10]      // Gold (±5%)

    private let toolID = "resistor"

    private var decoded: (ohms: Double, tolerance: Double) {
        CDCKResistorEngine.decode(band1: band1, band2: band2,
                                  multiplier: multiplier, tolerance: tolerance)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                resistorPreview
                    .padding(.horizontal, 16)

                CDCKResultCard(title: "Resistance",
                               value: CDCKResistorEngine.formatOhms(decoded.ohms),
                               unit: "",
                               note: "Tolerance ± \(CDCKFormatHelper.smart(decoded.tolerance)) %")
                    .padding(.horizontal, 16)

                CDCKCardView {
                    VStack(spacing: 16) {
                        bandPicker("Band 1 (1st digit)", CDCKResistorBand.digitBands, $band1)
                        bandPicker("Band 2 (2nd digit)", CDCKResistorBand.digitBands, $band2)
                        bandPicker("Multiplier", CDCKResistorBand.multiplierBands, $multiplier)
                        bandPicker("Tolerance", CDCKResistorBand.toleranceBands, $tolerance)
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 20)
            }
            .padding(.top, 12)
        }
        .cdckScreenBackground()
        .navigationBarTitle("Resistor Decoder", displayMode: .inline)
        .toolbar { favoriteToolbarItem(store: store, toolID: toolID) }
    }

    /// A stylized resistor body with the four selected color bands.
    private var resistorPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: 0xE9D9B0))
                .frame(height: 70)
                .overlay(
                    HStack(spacing: 14) {
                        bandStripe(band1.color)
                        bandStripe(band2.color)
                        bandStripe(multiplier.color)
                        Spacer()
                        bandStripe(tolerance.color)
                    }
                    .padding(.horizontal, 26)
                )
                .overlay(
                    // Lead wires.
                    HStack {
                        Rectangle().fill(Color.gray).frame(width: 16, height: 3)
                        Spacer()
                        Rectangle().fill(Color.gray).frame(width: 16, height: 3)
                    }
                )
        }
    }

    private func bandStripe(_ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 10, height: 60)
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.2), lineWidth: 0.5))
    }

    private func bandPicker(_ title: String, _ bands: [CDCKResistorBand], _ binding: Binding<CDCKResistorBand>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(CDCKTheme.textSecondary)
            Menu {
                ForEach(bands) { band in
                    Button {
                        CDCKHapticHelper.selection()
                        binding.wrappedValue = band
                    } label: {
                        Text(band.name)
                    }
                }
            } label: {
                HStack {
                    Circle().fill(binding.wrappedValue.color)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Color.white.opacity(0.25), lineWidth: 0.5))
                    Text(binding.wrappedValue.name)
                        .foregroundColor(CDCKTheme.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 8).fill(CDCKTheme.inputFill))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(CDCKTheme.cardStroke, lineWidth: 1))
            }
        }
    }
}
