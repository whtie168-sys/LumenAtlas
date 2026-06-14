//
//  CDCKHapticHelper.swift
//  TechRefPro
//
//  Thin wrapper around UIKit haptic feedback generators.
//

import UIKit

/// Lightweight haptic feedback helper. Safe to call from anywhere on the
/// main thread; no-ops gracefully on devices without a Taptic Engine.
enum CDCKHapticHelper {

    /// A light selection tick, e.g. when toggling a favorite.
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    /// An impact tap with the given style.
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    /// A notification feedback, e.g. on a successful calculation.
    static func notify(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func success() { notify(.success) }
    static func warning() { notify(.warning) }
}
