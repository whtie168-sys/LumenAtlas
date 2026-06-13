//
//  Theme.swift
//  FocusToolkit
//
//  Centralized design tokens: colors, gradients, spacing, corner radii.
//  Dark mode first. Accent: blue→green per spec.
//

import SwiftUI

enum Theme {
    // MARK: Colors
    static let accent = Color(hex: "#22C55E")      // green
    static let accentBlue = Color(hex: "#3B82F6")  // blue
    static let accentAlt = Color(hex: "#10B981")

    static let background = Color(hex: "#0B0F14")
    static let backgroundElevated = Color(hex: "#11161D")
    static let card = Color(hex: "#161C24")
    static let cardStroke = Color.white.opacity(0.06)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)
    static let textTertiary = Color.white.opacity(0.38)

    static let danger = Color(hex: "#EF4444")
    static let warning = Color(hex: "#F59E0B")

    // MARK: Gradients
    static let accentGradient = LinearGradient(
        colors: [accentBlue, accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let ringGradient = AngularGradient(
        colors: [accentBlue, accent, accentAlt, accentBlue],
        center: .center
    )

    /// Premium multi-stop gradient for the Journey hero card.
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "#7C3AED"), Color(hex: "#3B82F6"), Color(hex: "#22C55E")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "#0B0F14"), Color(hex: "#0E141B")],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: Metrics
    static let cornerRadius: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12
    static let spacing: CGFloat = 16
}

// MARK: - Color hex helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
