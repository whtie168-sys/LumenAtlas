//
//  TagChip.swift
//  FocusToolkit
//
//  Small pill used for note tags and repeat labels.
//

import SwiftUI

struct TagChip: View {
    let text: String
    let systemImage: String
    var color: Color = Theme.accent
    var filled: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 12, weight: .semibold))
        }
        .foregroundStyle(filled ? Color.black : color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule().fill(filled ? color : color.opacity(0.15))
        )
    }
}
