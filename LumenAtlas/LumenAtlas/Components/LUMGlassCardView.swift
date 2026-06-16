//
//  LUMGlassCardView.swift
//  LumenAtlas
//
//  A reusable glassmorphism container: blurred translucent fill, hairline
//  gradient border and a soft neon shadow. The building block for nearly every
//  panel in the app.
//

import UIKit

class LUMGlassCardView: UIView {

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let borderLayer = CAGradientLayer()
    private let shapeMask = CAShapeLayer()

    /// Content added by callers goes here, inset from the card edges.
    let contentView = UIView()

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
        layer.cornerRadius = LUMMetrics.cornerRadius
        layer.cornerCurve = .continuous

        // Soft neon drop shadow.
        layer.shadowColor = LUMPalette.neonPurple.cgColor
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 18
        layer.shadowOffset = CGSize(width: 0, height: 8)

        blurView.layer.cornerRadius = LUMMetrics.cornerRadius
        blurView.layer.cornerCurve = .continuous
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurView)

        // A faint raised fill on top of the blur for depth.
        let tint = UIView()
        tint.backgroundColor = LUMPalette.surface.withAlphaComponent(0.55)
        tint.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(tint)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(contentView)

        // Gradient hairline border drawn via a masked gradient layer.
        borderLayer.colors = [LUMPalette.neonBlue.withAlphaComponent(0.7).cgColor,
                              LUMPalette.neonPurple.withAlphaComponent(0.5).cgColor]
        borderLayer.startPoint = CGPoint(x: 0, y: 0)
        borderLayer.endPoint = CGPoint(x: 1, y: 1)
        shapeMask.lineWidth = 1.0
        shapeMask.fillColor = UIColor.clear.cgColor
        shapeMask.strokeColor = UIColor.white.cgColor
        borderLayer.mask = shapeMask
        layer.addSublayer(borderLayer)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),

            tint.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            tint.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor),
            tint.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            tint.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: LUMMetrics.cardPadding),
            contentView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -LUMMetrics.cardPadding),
            contentView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: LUMMetrics.cardPadding),
            contentView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -LUMMetrics.cardPadding)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = bounds
        shapeMask.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: LUMMetrics.cornerRadius
        ).cgPath
    }
}
