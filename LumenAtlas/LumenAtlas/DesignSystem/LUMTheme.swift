//
//  LUMTheme.swift
//  LumenAtlas
//
//  Centralised visual language: the neon-on-dark palette, gradients, typography
//  and spacing tokens. Every custom component reads from here so the look stays
//  consistent and a restyle is a one-file change.
//

import UIKit

enum LUMPalette {

    // MARK: Surfaces
    static let background = UIColor(hex: 0x0A0B14)
    static let surface = UIColor(hex: 0x141627)
    static let surfaceRaised = UIColor(hex: 0x1C1F36)

    // MARK: Neon accents
    static let neonBlue = UIColor(hex: 0x3FA9FF)
    static let neonPurple = UIColor(hex: 0x9B5CFF)
    static let neonCyan = UIColor(hex: 0x37E2D5)
    static let neonPink = UIColor(hex: 0xFF5CA8)

    // MARK: Text
    static let textPrimary = UIColor(hex: 0xF2F4FF)
    static let textSecondary = UIColor(hex: 0x9AA0C0)
    static let textMuted = UIColor(hex: 0x5C6184)

    // MARK: Semantic (signal axes)
    static func color(for axis: LUMSignalAxis) -> UIColor {
        switch axis {
        case .emotion: return neonPink
        case .energy:  return neonCyan
        case .stress:  return UIColor(hex: 0xFF7A59)
        case .focus:   return neonBlue
        }
    }

    /// Maps a 0...100 mood/composite score to a colour ramp from warm-warning
    /// red through amber to cool neon green.
    static func moodColor(_ score: Double) -> UIColor {
        let t = max(0, min(1, score / 100))
        if t < 0.5 {
            return UIColor(hex: 0xFF6B6B).blended(to: UIColor(hex: 0xFFC857), amount: t * 2)
        } else {
            return UIColor(hex: 0xFFC857).blended(to: UIColor(hex: 0x37E2D5), amount: (t - 0.5) * 2)
        }
    }

    // MARK: Tag palette
    static let tagColors: [UIColor] = [
        neonBlue, neonPurple, neonCyan, neonPink,
        UIColor(hex: 0xFFC857), UIColor(hex: 0x6BCB77),
        UIColor(hex: 0xFF7A59), UIColor(hex: 0x8E9BFF)
    ]
    static var tagColorCount: Int { tagColors.count }
    static func tagColor(_ index: Int) -> UIColor {
        tagColors[((index % tagColorCount) + tagColorCount) % tagColorCount]
    }

    /// The signature gradient used on primary buttons and the launch glow.
    static var primaryGradient: [CGColor] {
        [neonBlue.cgColor, neonPurple.cgColor]
    }
}

enum LUMMetrics {
    static let cornerRadius: CGFloat = 18
    static let cardPadding: CGFloat = 16
    static let screenInset: CGFloat = 20
    static let spacing: CGFloat = 12
}

enum LUMFont {
    static func title(_ size: CGFloat = 28) -> UIFont {
        .systemFont(ofSize: size, weight: .bold)
    }
    static func heading(_ size: CGFloat = 20) -> UIFont {
        .systemFont(ofSize: size, weight: .semibold)
    }
    static func body(_ size: CGFloat = 15) -> UIFont {
        .systemFont(ofSize: size, weight: .regular)
    }
    static func mono(_ size: CGFloat = 32) -> UIFont {
        .monospacedDigitSystemFont(ofSize: size, weight: .bold)
    }
    static func caption(_ size: CGFloat = 12) -> UIFont {
        .systemFont(ofSize: size, weight: .medium)
    }
}

// MARK: - UIColor utilities

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    /// Linear blend toward another colour by `amount` (0...1).
    func blended(to other: UIColor, amount: CGFloat) -> UIColor {
        let t = max(0, min(1, amount))
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        return UIColor(red: r1 + (r2 - r1) * t,
                       green: g1 + (g2 - g1) * t,
                       blue: b1 + (b2 - b1) * t,
                       alpha: a1 + (a2 - a1) * t)
    }
}
