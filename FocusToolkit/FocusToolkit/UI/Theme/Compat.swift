//
//  Compat.swift
//  FocusToolkit
//
//  Backward-compatibility shims so the app runs on iOS 15 while still using
//  nicer iOS 16/17 behaviors where available.
//

import SwiftUI

// MARK: - Navigation

/// `NavigationStack` on iOS 16+, `NavigationView` (stack style) on iOS 15.
struct CompatNav<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack { content }
        } else {
            NavigationView { content }
                .navigationViewStyle(.stack)
        }
    }
}

// MARK: - View modifiers

extension View {
    /// Hide the default scroll/list background (iOS 16+). On iOS 15 we rely on
    /// `UITableView`/`UITextView` appearance being cleared at launch.
    @ViewBuilder
    func compatHideScrollBackground() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollContentBackground(.hidden)
        } else {
            self
        }
    }

    /// Apply a medium+large detent on iOS 16+, full sheet on iOS 15.
    @ViewBuilder
    func compatDetentsMedium() -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.medium, .large])
        } else {
            self
        }
    }

    /// Apply a fixed-height detent on iOS 16+, full sheet on iOS 15.
    @ViewBuilder
    func compatDetentHeight(_ height: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents([.height(height)])
        } else {
            self
        }
    }

    /// Animated numeric digit roll on iOS 16+, no-op on iOS 15.
    @ViewBuilder
    func contentTransitionNumeric() -> some View {
        if #available(iOS 16.0, *) {
            self.contentTransition(.numericText())
        } else {
            self
        }
    }
}

// MARK: - Text

extension Text {
    /// Letter spacing on iOS 16+, no-op on iOS 15.
    @ViewBuilder
    func compatTracking(_ value: CGFloat) -> some View {
        if #available(iOS 16.0, *) {
            self.tracking(value)
        } else {
            self
        }
    }
}
