//
//  LUMGraphViewModel.swift
//  LumenAtlas
//
//  Builds the relationship graph and runs a small force-directed layout so the
//  view controller only has to draw positioned nodes and edges. The layout is
//  deterministic (seeded from tag hashes) so the graph doesn't jump around
//  between appearances.
//

import CoreGraphics
import Foundation

final class LUMGraphViewModel {

    struct PositionedNode {
        let node: LUMGraphNode
        var position: CGPoint
        let radius: CGFloat
    }

    private let eventService: LUMEventServing
    private let graphService: LUMGraphService
    private var token: LUMSubscriptionToken?

    var onChange: (() -> Void)?

    private(set) var graph: LUMGraph = .empty
    private(set) var positioned: [String: PositionedNode] = [:]

    /// The canvas the layout was computed for; recomputed when it changes.
    private var canvasSize: CGSize = .zero

    init(eventService: LUMEventServing, graphService: LUMGraphService) {
        self.eventService = eventService
        self.graphService = graphService
        token = eventService.changes.subscribe { [weak self] in self?.rebuild() }
        rebuild()
    }

    var isEmpty: Bool { graph.nodes.isEmpty }
    var edges: [LUMGraphEdge] { graph.edges }

    func rebuild() {
        graph = graphService.buildGraph(from: eventService.events)
        if canvasSize != .zero { layout(in: canvasSize) }
        onChange?()
    }

    /// Force-directed layout: nodes repel each other, edges act as springs, and
    /// a weak centring force keeps the cloud on-screen. Run for a fixed number
    /// of iterations — personal graphs are small, so this settles in well under
    /// a frame.
    func layout(in size: CGSize) {
        canvasSize = size
        guard !graph.nodes.isEmpty, size != .zero else { positioned = [:]; return }

        let maxWeight = max(1, graph.nodes.map(\.weight).max() ?? 1)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        // Seed positions deterministically on a circle (hash-based angle).
        var points: [String: CGPoint] = [:]
        var velocities: [String: CGVector] = [:]
        let radius = min(size.width, size.height) * 0.32
        for node in graph.nodes {
            let angle = Double(abs(node.tag.hashValue) % 360) * .pi / 180
            points[node.tag] = CGPoint(x: center.x + cos(angle) * radius,
                                       y: center.y + sin(angle) * radius)
            velocities[node.tag] = .zero
        }

        let iterations = 120
        let repulsion: CGFloat = 4200
        let springLength: CGFloat = 90
        let damping: CGFloat = 0.85

        for _ in 0..<iterations {
            var forces: [String: CGVector] = [:]
            for node in graph.nodes { forces[node.tag] = .zero }

            // Pairwise repulsion.
            let tags = graph.nodes.map(\.tag)
            for i in 0..<tags.count {
                for j in (i + 1)..<tags.count {
                    let a = points[tags[i]]!, b = points[tags[j]]!
                    var dx = a.x - b.x, dy = a.y - b.y
                    var distSq = dx * dx + dy * dy
                    if distSq < 0.01 { dx = 0.1; dy = 0.1; distSq = 0.02 }
                    let force = repulsion / distSq
                    let dist = distSq.squareRoot()
                    let fx = dx / dist * force, fy = dy / dist * force
                    forces[tags[i]]!.dx += fx; forces[tags[i]]!.dy += fy
                    forces[tags[j]]!.dx -= fx; forces[tags[j]]!.dy -= fy
                }
            }

            // Edge springs (stronger edges pull tighter).
            for edge in graph.edges {
                guard let a = points[edge.source], let b = points[edge.target] else { continue }
                let dx = b.x - a.x, dy = b.y - a.y
                let dist = max(1, (dx * dx + dy * dy).squareRoot())
                let target = springLength * CGFloat(1.4 - edge.strength)
                let displacement = dist - target
                let k: CGFloat = 0.02 * CGFloat(0.5 + edge.strength)
                let fx = dx / dist * displacement * k
                let fy = dy / dist * displacement * k
                forces[edge.source]!.dx += fx; forces[edge.source]!.dy += fy
                forces[edge.target]!.dx -= fx; forces[edge.target]!.dy -= fy
            }

            // Integrate with centring + damping.
            for tag in tags {
                var v = velocities[tag]!
                v.dx = (v.dx + forces[tag]!.dx) * damping
                v.dy = (v.dy + forces[tag]!.dy) * damping
                var p = points[tag]!
                p.x += v.dx; p.y += v.dy
                // Gentle pull to centre.
                p.x += (center.x - p.x) * 0.01
                p.y += (center.y - p.y) * 0.01
                points[tag] = p
                velocities[tag] = v
            }
        }

        // Clamp into bounds and package with a weight-derived radius.
        var result: [String: PositionedNode] = [:]
        for node in graph.nodes {
            let r = 16 + CGFloat(node.weight) / CGFloat(maxWeight) * 22
            var p = points[node.tag]!
            p.x = min(max(p.x, r + 8), size.width - r - 8)
            p.y = min(max(p.y, r + 8), size.height - r - 28)
            result[node.tag] = PositionedNode(node: node, position: p, radius: r)
        }
        positioned = result
    }
}
