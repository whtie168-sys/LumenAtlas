//
//  CDCKFavorite.swift
//  TechRefPro
//
//  A typed reference to any favorited reference-library item.
//

import Foundation

/// Categories of items that can be favorited across the app.
enum CDCKFavoriteType: String, Codable, CaseIterable {
    case cable
    case wireGauge
    case breaker
    case motor
    case safety
    case formula

    var displayName: String {
        switch self {
        case .cable:     return "Cable"
        case .wireGauge: return "Wire Gauge"
        case .breaker:   return "Breaker"
        case .motor:     return "Motor"
        case .safety:    return "Safety"
        case .formula:   return "Calculator"
        }
    }

    var systemImage: String {
        switch self {
        case .cable:     return "cable.connector"
        case .wireGauge: return "ruler"
        case .breaker:   return "switch.2"
        case .motor:     return "gearshape.2"
        case .safety:    return "exclamationmark.shield"
        case .formula:   return "function"
        }
    }
}

/// A favorite marker linking a type to a referenced item's identifier.
struct CDCKFavorite: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: String          // raw value of CDCKFavoriteType
    var referenceId: UUID

    init(id: UUID = UUID(), type: String, referenceId: UUID) {
        self.id = id
        self.type = type
        self.referenceId = referenceId
    }

    init(id: UUID = UUID(), type: CDCKFavoriteType, referenceId: UUID) {
        self.id = id
        self.type = type.rawValue
        self.referenceId = referenceId
    }

    var favoriteType: CDCKFavoriteType? { CDCKFavoriteType(rawValue: type) }
}
