//
//  CardView.swift
//  FocusToolkit
//
//  Reusable card container: rounded, subtly stroked, minimal shadow.
//

import SwiftUI

struct Card<Content: View>: View {
    var padding: CGFloat = Theme.spacing
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .fill(Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                    .stroke(Theme.cardStroke, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
    }
}

/// Convenience modifier form.
extension View {
    func cardStyle(padding: CGFloat = Theme.spacing) -> some View {
        Card(padding: padding) { self }
    }
}
