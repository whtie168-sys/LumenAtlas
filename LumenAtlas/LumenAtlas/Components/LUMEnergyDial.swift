//
//  LUMEnergyDial.swift
//  LumenAtlas
//
//  Circular progress control rendering a 0...100 value as a neon arc with an
//  animated sweep and a numeric readout in the centre. Used on the dashboard
//  and analytics headers.
//

import UIKit

final class LUMEnergyDial: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let valueLabel = UILabel()
    private let captionLabel = UILabel()

    private var tint: UIColor = LUMPalette.neonCyan
    private let lineWidth: CGFloat = 12

    /// 0...100. Use `setValue(_:animated:)` to animate the sweep.
    private(set) var value: Int = 0

    init(caption: String, tint: UIColor = LUMPalette.neonCyan) {
        super.init(frame: .zero)
        self.tint = tint
        captionLabel.text = caption.uppercased()
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = LUMPalette.surfaceRaised.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = tint.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        progressLayer.shadowColor = tint.cgColor
        progressLayer.shadowRadius = 8
        progressLayer.shadowOpacity = 0.8
        progressLayer.shadowOffset = .zero
        layer.addSublayer(progressLayer)

        valueLabel.font = LUMFont.mono(30)
        valueLabel.textColor = LUMPalette.textPrimary
        valueLabel.textAlignment = .center
        valueLabel.text = "0"
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(valueLabel)

        captionLabel.font = LUMFont.caption(11)
        captionLabel.textColor = LUMPalette.textSecondary
        captionLabel.textAlignment = .center
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(captionLabel)

        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -6),
            captionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            captionLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 2)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset = lineWidth / 2 + 2
        let radius = min(bounds.width, bounds.height) / 2 - inset
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        // Start at the top, sweep clockwise leaving a small gap at the bottom.
        let start = -CGFloat.pi / 2
        let end = start + 2 * .pi
        let path = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: start, endAngle: end, clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    func setValue(_ newValue: Int, animated: Bool) {
        let clamped = min(max(newValue, 0), 100)
        value = clamped
        let fraction = CGFloat(clamped) / 100.0

        // Re-tint based on the value so a low reading reads as warning.
        let color = tint
        progressLayer.strokeColor = color.cgColor
        progressLayer.shadowColor = color.cgColor
        valueLabel.text = "\(clamped)"

        if animated {
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = progressLayer.presentation()?.strokeEnd ?? 0
            anim.toValue = fraction
            anim.duration = 0.8
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            progressLayer.add(anim, forKey: "sweep")
        }
        progressLayer.strokeEnd = fraction
    }
}
