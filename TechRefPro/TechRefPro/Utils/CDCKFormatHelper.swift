//
//  CDCKFormatHelper.swift
//  TechRefPro
//
//  Number / date formatting helpers shared across screens.
//

import Foundation

/// Shared formatting utilities for displaying engineering values.
enum CDCKFormatHelper {

    /// Formats a value with adaptive precision (more decimals for small numbers).
    static func smart(_ value: Double) -> String {
        guard value.isFinite else { return "—" }
        let magnitude = abs(value)
        let digits: Int
        switch magnitude {
        case 0..<1:      digits = 3
        case 1..<10:     digits = 2
        case 10..<1000:  digits = 1
        default:         digits = 0
        }
        return String(format: "%.\(digits)f", value)
    }

    /// Formats with a fixed number of fraction digits.
    static func fixed(_ value: Double, _ digits: Int) -> String {
        guard value.isFinite else { return "—" }
        return String(format: "%.\(digits)f", value)
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    static func dateTime(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
