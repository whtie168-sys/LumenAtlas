//
//  CDCKInputField.swift
//  TechRefPro
//
//  Dark-styled numeric input field plus the shared screen background.
//

import SwiftUI

/// A labelled numeric text field with an optional unit suffix.
/// Uses a plain `@State`-bound `String` (no `@FocusState`) for iOS 14.
struct CDCKInputField: View {
    let title: String
    var unit: String = ""
    var placeholder: String = "0"
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(CDCKTheme.textSecondary)
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .foregroundColor(CDCKTheme.textPrimary)
                if !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(CDCKTheme.inputFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(CDCKTheme.inputStroke, lineWidth: 1)
            )
        }
    }
}

/// A segmented picker styled for the dark theme.
struct CDCKSegmented<T: Hashable>: View {
    let title: String
    @Binding var selection: T
    let options: [(label: String, value: T)]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !title.isEmpty {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(CDCKTheme.textSecondary)
            }
            Picker(title, selection: $selection) {
                ForEach(options, id: \.value) { option in
                    Text(option.label).tag(option.value)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

extension View {
    /// Applies the standard full-screen dark-tech gradient background.
    func cdckScreenBackground() -> some View {
        background(CDCKTheme.backgroundGradient.ignoresSafeArea())
    }
}
