//
//  LUMLineChartView.swift
//  LumenAtlas
//
//  A lightweight neon line chart for trend series. Draws a gradient-stroked
//  path with a soft fill beneath and an animated draw-in. Used across the
//  analytics screens; deliberately dependency-free.
//

import UIKit

final class LUMLineChartView: UIView {

    private let lineLayer = CAShapeLayer()
    private let fillLayer = CAGradientLayer()
    private let fillMask = CAShapeLayer()
    private let gridLayer = CAShapeLayer()

    private var points: [LUMTrendPoint] = []
    private var tint: UIColor = LUMPalette.neonBlue

    init() {
        super.init(frame: .zero)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear

        gridLayer.strokeColor = LUMPalette.textMuted.withAlphaComponent(0.18).cgColor
        gridLayer.lineWidth = 0.5
        layer.addSublayer(gridLayer)

        fillLayer.colors = [tint.withAlphaComponent(0.35).cgColor,
                            tint.withAlphaComponent(0.0).cgColor]
        fillLayer.mask = fillMask
        layer.addSublayer(fillLayer)

        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = tint.cgColor
        lineLayer.lineWidth = 2.5
        lineLayer.lineJoin = .round
        lineLayer.lineCap = .round
        lineLayer.shadowColor = tint.cgColor
        lineLayer.shadowRadius = 6
        lineLayer.shadowOpacity = 0.6
        lineLayer.shadowOffset = .zero
        layer.addSublayer(lineLayer)
    }

    func update(points: [LUMTrendPoint], tint: UIColor) {
        self.points = points
        self.tint = tint
        lineLayer.strokeColor = tint.cgColor
        lineLayer.shadowColor = tint.cgColor
        fillLayer.colors = [tint.withAlphaComponent(0.35).cgColor,
                            tint.withAlphaComponent(0.0).cgColor]
        setNeedsLayout()
        layoutIfNeeded()
        animateDrawIn()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fillLayer.frame = bounds
        renderPaths()
    }

    private func renderPaths() {
        guard points.count > 1, bounds.width > 0 else {
            lineLayer.path = nil
            fillMask.path = nil
            return
        }

        // The signal axes share a fixed 0...100 domain so charts are comparable.
        let minValue = 0.0
        let maxValue = 100.0
        let range = maxValue - minValue

        let inset: CGFloat = 8
        let plotWidth = bounds.width - inset * 2
        let plotHeight = bounds.height - inset * 2

        func position(_ index: Int, _ value: Double) -> CGPoint {
            let x = inset + plotWidth * CGFloat(index) / CGFloat(points.count - 1)
            let normalized = (value - minValue) / range
            let y = inset + plotHeight * (1 - CGFloat(normalized))
            return CGPoint(x: x, y: y)
        }

        // Gridlines at 0/25/50/75/100.
        let grid = UIBezierPath()
        for fraction in stride(from: 0.0, through: 1.0, by: 0.25) {
            let y = inset + plotHeight * CGFloat(1 - fraction)
            grid.move(to: CGPoint(x: inset, y: y))
            grid.addLine(to: CGPoint(x: bounds.width - inset, y: y))
        }
        gridLayer.path = grid.cgPath

        // Smooth-ish line using quad curves between midpoints.
        let line = UIBezierPath()
        let first = position(0, points[0].value)
        line.move(to: first)
        for i in 1..<points.count {
            let current = position(i, points[i].value)
            let previous = position(i - 1, points[i - 1].value)
            let mid = CGPoint(x: (previous.x + current.x) / 2,
                              y: (previous.y + current.y) / 2)
            line.addQuadCurve(to: mid, controlPoint: previous)
            if i == points.count - 1 {
                line.addLine(to: current)
            }
        }
        lineLayer.path = line.cgPath

        // Fill mask closes the path down to the baseline.
        let fill = UIBezierPath(cgPath: line.cgPath)
        fill.addLine(to: CGPoint(x: bounds.width - inset, y: bounds.height - inset))
        fill.addLine(to: CGPoint(x: inset, y: bounds.height - inset))
        fill.close()
        fillMask.path = fill.cgPath
    }

    private func animateDrawIn() {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = 0
        anim.toValue = 1
        anim.duration = 0.7
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        lineLayer.add(anim, forKey: "draw")
    }
}
