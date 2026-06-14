//
//  CDCKCardView.swift
//  TechRefPro
//
//  Reusable card container and small building-block views used throughout
//  the app to keep the dark-tech look consistent.
//

import SwiftUI

/// A rounded translucent card container with a subtle stroke.
struct CDCKCardView<Content: View>: View {
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(CDCKTheme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(CDCKTheme.cardStroke, lineWidth: 1)
            )
    }
}

/// A labelled value row, e.g. "Voltage    230 V".
struct CDCKValueRow: View {
    let label: String
    let value: String
    var valueColor: Color = CDCKTheme.textPrimary
    var mono: Bool = true

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(CDCKTheme.textSecondary)
            Spacer(minLength: 12)
            Text(value)
                .font(mono ? .system(size: 15, weight: .semibold, design: .monospaced)
                           : .system(size: 15, weight: .semibold))
                .foregroundColor(valueColor)
        }
    }
}

/// A favorite (star) toggle button with haptic feedback.
struct CDCKFavoriteButton: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button {
            CDCKHapticHelper.selection()
            action()
        } label: {
            Image(systemName: isOn ? "star.fill" : "star")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isOn ? CDCKTheme.amber : CDCKTheme.textTertiary)
        }
        .buttonStyle(.plain)
    }
}

/// A primary filled action button (electric blue).
struct CDCKPrimaryButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: {
            CDCKHapticHelper.impact(.medium)
            action()
        }) {
            HStack(spacing: 8) {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(CDCKTheme.accent)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// A section header with an SF Symbol.
struct CDCKSectionHeader: View {
    let title: String
    var systemImage: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let systemImage = systemImage {
                Image(systemName: systemImage)
                    .foregroundColor(CDCKTheme.accent)
            }
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(CDCKTheme.textSecondary)
                .textCase(.uppercase)
            Spacer()
        }
    }
}

/// An empty-state placeholder.
struct CDCKEmptyState: View {
    let systemImage: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .thin))
                .foregroundColor(CDCKTheme.textTertiary)
            Text(title)
                .font(.headline)
                .foregroundColor(CDCKTheme.textSecondary)
            Text(message)
                .font(.subheadline)
                .foregroundColor(CDCKTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}
