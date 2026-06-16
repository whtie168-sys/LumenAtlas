//
//  LUMGraphNodeView.swift
//  LumenAtlas
//
//  A single animated node in the memory graph: a pulsing neon disc sized by
//  tag weight and tinted by mood, with the tag label beneath. Drawn on top of
//  the edge layer by the graph view controller.
//

import UIKit

final class LUMGraphNodeView: UIView {

    private let disc = CALayer()
    private let ring = CAShapeLayer()
    private let label = UILabel()

    let node: LUMGraphNode
    /// The on-canvas radius decided by the layout engine.
    let radius: CGFloat

    init(node: LUMGraphNode, radius: CGFloat) {
        self.node = node
        self.radius = radius
        super.init(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2 + 18))
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        let color = LUMPalette.moodColor(node.mood)

        disc.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        disc.cornerRadius = radius
        disc.backgroundColor = color.withAlphaComponent(0.85).cgColor
        disc.shadowColor = color.cgColor
        disc.shadowRadius = 10
        disc.shadowOpacity = 0.7
        disc.shadowOffset = .zero
        layer.addSublayer(disc)

        ring.frame = disc.frame
        ring.path = UIBezierPath(ovalIn: disc.bounds).cgPath
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = color.cgColor
        ring.lineWidth = 2
        ring.opacity = 0.6
        layer.addSublayer(ring)

        label.text = node.tag
        label.font = LUMFont.caption(11)
        label.textColor = LUMPalette.textPrimary
        label.textAlignment = .center
        label.frame = CGRect(x: -20, y: radius * 2 + 2, width: radius * 2 + 40, height: 14)
        addSubview(label)

        startPulse()
    }

    /// A gentle breathing animation so the graph feels alive. Phase is derived
    /// from the tag hash so nodes don't pulse in lockstep.
    private func startPulse() {
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.fromValue = 1.0
        pulse.toValue = 1.08
        pulse.duration = 1.6 + Double(abs(node.tag.hashValue) % 80) / 100.0
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        disc.add(pulse, forKey: "pulse")

        let ringPulse = CABasicAnimation(keyPath: "opacity")
        ringPulse.fromValue = 0.6
        ringPulse.toValue = 0.15
        ringPulse.duration = pulse.duration
        ringPulse.autoreverses = true
        ringPulse.repeatCount = .infinity
        ring.add(ringPulse, forKey: "ringPulse")
    }
}
