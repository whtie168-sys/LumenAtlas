//
//  LUMSignal.swift
//  LumenAtlas
//
//  The four measurable "life signals" that every event carries. Each is a
//  bounded scalar (0...100) so that downstream analytics can treat them
//  uniformly without per-axis special casing.
//

import Foundation

/// The axes along which a moment in life is sampled.
///
/// Keeping these as an enum (rather than four loose `Int` fields) lets the
/// analytics layer iterate over signals generically — every chart, average and
/// spike detector is written once and reused for all four axes.
enum LUMSignalAxis: String, CaseIterable, Codable {
    case emotion
    case energy
    case stress
    case focus

    /// Human-facing title used across the UI.
    var title: String {
        switch self {
        case .emotion: return "Emotion"
        case .energy:  return "Energy"
        case .stress:  return "Stress"
        case .focus:   return "Focus"
        }
    }

    /// Single-character glyph used in compact chart legends.
    var glyph: String {
        switch self {
        case .emotion: return "♥"
        case .energy:  return "⚡︎"
        case .stress:  return "▲"
        case .focus:   return "◎"
        }
    }

    /// For most axes a higher reading is "better". Stress is inverted: a high
    /// stress reading is a negative outcome. The analytics layer uses this to
    /// decide whether a spike is something to celebrate or to flag.
    var higherIsBetter: Bool {
        switch self {
        case .stress: return false
        default:      return true
        }
    }
}

/// A single reading on one axis, clamped to a valid range on construction so no
/// invalid value can enter the system from import, UI, or decoding.
struct LUMSignalReading: Codable, Equatable {
    static let range: ClosedRange<Int> = 0...100

    let axis: LUMSignalAxis
    let value: Int

    init(axis: LUMSignalAxis, value: Int) {
        self.axis = axis
        self.value = min(max(value, LUMSignalReading.range.lowerBound),
                         LUMSignalReading.range.upperBound)
    }

    /// Normalised 0...1 magnitude, convenient for drawing.
    var normalized: Double { Double(value) / 100.0 }
}
