//
//  LUMNeonButton.swift
//  LumenAtlas
//
//  Primary call-to-action control: an animated gradient fill with a press
//  spring and an outer glow that pulses on tap. Built on UIControl so it
//  participates in normal target/action wiring.
//

import UIKit

final class LUMNeonButton: UIControl {

    private let gradientLayer = CAGradientLayer()
    private let titleLabel = UILabel()
    private let glowLayer = CALayer()

    var title: String = "" {
        didSet { titleLabel.text = title }
    }

    /// Optional style: filled (default) or outline for secondary actions.
    enum Style { case filled, outline }
    private let style: Style

    init(title: String, style: Style = .filled) {
        self.style = style
        super.init(frame: .zero)
        self.title = title
        titleLabel.text = title
        configure()
    }

    required init?(coder: NSCoder) {
        self.style = .filled
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        clipsToBounds = false

        // Outer glow sits behind everything and animates on press.
        glowLayer.backgroundColor = LUMPalette.neonBlue.cgColor
        glowLayer.cornerRadius = 14
        glowLayer.opacity = 0
        glowLayer.shadowColor = LUMPalette.neonBlue.cgColor
        glowLayer.shadowRadius = 16
        glowLayer.shadowOpacity = 0.9
        glowLayer.shadowOffset = .zero
        layer.addSublayer(glowLayer)

        gradientLayer.colors = LUMPalette.primaryGradient
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 14
        gradientLayer.cornerCurve = .continuous
        layer.addSublayer(gradientLayer)

        if style == .outline {
            gradientLayer.opacity = 0
            layer.borderWidth = 1.5
            layer.borderColor = LUMPalette.neonBlue.cgColor
        }

        titleLabel.font = LUMFont.heading(16)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])

        addTarget(self, action: #selector(pressDown), for: [.touchDown, .touchDragEnter])
        addTarget(self, action: #selector(pressUp), for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        glowLayer.frame = bounds
    }

    // MARK: Press animation

    @objc private func pressDown() {
        animateScale(to: 0.96)
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = glowLayer.opacity
        fade.toValue = 0.6
        fade.duration = 0.18
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        glowLayer.add(fade, forKey: "glow")
    }

    @objc private func pressUp() {
        animateScale(to: 1.0)
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.6
        fade.toValue = 0
        fade.duration = 0.3
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        glowLayer.add(fade, forKey: "glow")
    }

    private func animateScale(to scale: CGFloat) {
        UIView.animate(withDuration: 0.25,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [.allowUserInteraction, .beginFromCurrentState]) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
}
