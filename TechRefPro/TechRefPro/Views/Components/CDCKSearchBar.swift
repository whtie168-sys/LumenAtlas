//
//  CDCKSearchBar.swift
//  TechRefPro
//
//  Dark-styled inline search bar (no UISearchController dependency).
//

import SwiftUI

/// A lightweight inline search field for filtering reference lists.
struct CDCKSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search"

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(CDCKTheme.textTertiary)
            TextField(placeholder, text: $text)
                .foregroundColor(CDCKTheme.textPrimary)
                .disableAutocorrection(true)
            if !text.isEmpty {
                Button {
                    text = ""
                    CDCKHapticHelper.selection()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 10).fill(CDCKTheme.inputFill))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(CDCKTheme.cardStroke, lineWidth: 1))
    }
}
