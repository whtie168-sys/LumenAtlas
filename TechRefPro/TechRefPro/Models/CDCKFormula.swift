//
//  CDCKFormula.swift
//  TechRefPro
//
//  Metadata describing a calculator formula, used to drive favorites.
//

import Foundation

/// A calculator formula descriptor. Used to mark calculators as favorite
/// and to enumerate the available calculation tools.
struct CDCKFormula: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var parameters: [String]
    var defaultUnits: [String: String]
    var isFavorite: Bool

    init(id: UUID = UUID(),
         name: String,
         parameters: [String],
         defaultUnits: [String: String] = [:],
         isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.parameters = parameters
        self.defaultUnits = defaultUnits
        self.isFavorite = isFavorite
    }
}
