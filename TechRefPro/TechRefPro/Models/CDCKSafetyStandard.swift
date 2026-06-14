//
//  CDCKSafetyStandard.swift
//  TechRefPro
//
//  A reference entry for safety standards and clearances.
//

import Foundation

/// A safety / standards reference entry (clearances, IP ratings, etc.).
struct CDCKSafetyStandard: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var content: String
    var category: String   // e.g. "Clearance", "IP Rating", "PPE"
    var isFavorite: Bool

    init(id: UUID = UUID(),
         title: String,
         content: String,
         category: String,
         isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.category = category
        self.isFavorite = isFavorite
    }
}
