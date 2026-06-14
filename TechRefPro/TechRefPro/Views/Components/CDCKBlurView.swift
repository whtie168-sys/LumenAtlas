//
//  CDCKBlurView.swift
//  TechRefPro
//
//  UIVisualEffectView wrapper providing blur without requiring iOS 15's
//  `.thinMaterial`, so it works on iOS 14.
//

import SwiftUI
import UIKit

/// A SwiftUI bridge to `UIVisualEffectView` for iOS 14-compatible blur.
struct CDCKBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemThinMaterialDark

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
