//
//  CDCKColorHelper.swift
//  TechRefPro
//
//  Centralised dark-tech color palette and hex helpers.
//

import SwiftUI

/// App-wide color palette. All colors are defined in code so the app
/// renders identically regardless of asset catalog contents.
enum CDCKTheme {

    /// Electric blue accent (#0A84FF).
    static let accent = Color(hex: 0x0A84FF)
    /// Secondary cyan used for highlights.
    static let cyan = Color(hex: 0x32D2FF)
    /// Warm amber used for warnings / safety.
    static let amber = Color(hex: 0xFF9F0A)
    /// Success green.
    static let green = Color(hex: 0x30D158)

    /// Background gradient stops: #0A0A0A → #1C1C1E.
    static let bgTop = Color(hex: 0x0A0A0A)
    static let bgBottom = Color(hex: 0x1C1C1E)

    /// Card fill (semi-transparent dark).
    static let card = Color.white.opacity(0.06)
    static let cardStroke = Color.white.opacity(0.10)

    /// Text colors.
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)

    /// Input field fill / border.
    static let inputFill = Color.white.opacity(0.05)
    static let inputStroke = accent.opacity(0.55)

    /// The standard background gradient used on every screen.
    static var backgroundGradient: LinearGradient {
        LinearGradient(colors: [bgTop, bgBottom],
                       startPoint: .top,
                       endPoint: .bottom)
    }
}

extension Color {
    /// Creates a color from a 24-bit RGB integer literal, e.g. `Color(hex: 0x0A84FF)`.
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
