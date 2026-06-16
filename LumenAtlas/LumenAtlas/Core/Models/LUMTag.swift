//
//  LUMTag.swift
//  LumenAtlas
//
//  A managed tag with display metadata. Events store bare slug strings; this
//  type is the user-curated layer on top (colour, pin state, creation date)
//  surfaced by the tag-management screen.
//

import Foundation

struct LUMTag: Codable, Equatable, Identifiable {
    var id: String { slug }
    /// Normalised lower-cased key — matches the strings stored on events.
    let slug: String
    /// Display name as originally typed by the user.
    let displayName: String
    /// Index into `LUMPalette.tagColors`, kept as an Int so the model stays
    /// free of any UIKit dependency.
    let colorIndex: Int
    let isPinned: Bool
    let createdAt: Date

    init(displayName: String,
         colorIndex: Int = 0,
         isPinned: Bool = false,
         createdAt: Date = Date()) {
        self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.slug = self.displayName.lowercased()
        self.colorIndex = colorIndex
        self.isPinned = isPinned
        self.createdAt = createdAt
    }

    func updating(colorIndex: Int? = nil, isPinned: Bool? = nil) -> LUMTag {
        var copy = self
        copy = LUMTag(displayName: displayName,
                      colorIndex: colorIndex ?? self.colorIndex,
                      isPinned: isPinned ?? self.isPinned,
                      createdAt: createdAt)
        return copy
    }
}
