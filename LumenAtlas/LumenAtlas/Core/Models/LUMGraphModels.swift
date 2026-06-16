//
//  LUMGraphModels.swift
//  LumenAtlas
//
//  The relationship graph. Nodes are tags; edges encode how often two tags
//  co-occur and how correlated their events are in time. This is the structural
//  centrepiece that distinguishes the app from a flat list of entries.
//

import Foundation

/// A node in the relationship graph — one tag plus the aggregate stats that
/// determine how it is drawn (size from weight, tint from mood).
struct LUMGraphNode: Equatable, Identifiable {
    var id: String { tag }
    let tag: String
    /// Number of events carrying this tag — drives node radius.
    let weight: Int
    /// Mean composite score of events carrying the tag — drives node colour.
    let mood: Double
}

/// An undirected weighted edge between two tag nodes.
struct LUMGraphEdge: Equatable, Identifiable {
    let id: String
    let source: String
    let target: String
    /// Raw count of events in which both tags appeared together.
    let coOccurrence: Int
    /// 0...1 strength combining co-occurrence frequency with temporal proximity.
    let strength: Double

    init(source: String, target: String, coOccurrence: Int, strength: Double) {
        // Canonical ordering so an edge has a stable identity regardless of the
        // order the pair was discovered in.
        let ordered = [source, target].sorted()
        self.source = ordered[0]
        self.target = ordered[1]
        self.id = "\(ordered[0])::\(ordered[1])"
        self.coOccurrence = coOccurrence
        self.strength = strength
    }
}

/// The full graph plus a precomputed adjacency map for layout and traversal.
struct LUMGraph: Equatable {
    let nodes: [LUMGraphNode]
    let edges: [LUMGraphEdge]

    /// tag -> neighbouring tags, built once so the force layout and the
    /// "related tags" UI don't rescan edges repeatedly.
    let adjacency: [String: [String]]

    static let empty = LUMGraph(nodes: [], edges: [], adjacency: [:])

    func neighbors(of tag: String) -> [String] { adjacency[tag] ?? [] }
}
