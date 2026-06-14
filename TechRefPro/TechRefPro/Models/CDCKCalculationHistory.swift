//
//  CDCKCalculationHistory.swift
//  TechRefPro
//
//  A persisted record of a single calculation.
//

import Foundation

/// One entry in the calculation history log.
struct CDCKCalculationHistory: Identifiable, Codable, Equatable {
    var id = UUID()
    var formulaName: String
    var inputs: [String: Double]
    var result: Double
    var resultUnit: String
    var timestamp: Date

    init(id: UUID = UUID(),
         formulaName: String,
         inputs: [String: Double],
         result: Double,
         resultUnit: String = "",
         timestamp: Date = Date()) {
        self.id = id
        self.formulaName = formulaName
        self.inputs = inputs
        self.result = result
        self.resultUnit = resultUnit
        self.timestamp = timestamp
    }
}
