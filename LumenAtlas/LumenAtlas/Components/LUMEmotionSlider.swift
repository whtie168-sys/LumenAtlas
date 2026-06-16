//
//  LUMEmotionSlider.swift
//  LumenAtlas
//
//  A custom 0...100 slider whose track is a live gradient and whose thumb glows
//  in the axis colour. Used on the Add Event screen for each signal axis.
//

import UIKit

final class LUMEmotionSlider: UIControl {

    private let trackLayer = CAGradientLayer()
    private let filledLayer = CALayer()
    private let thumbView = UIView()
    private let thumbGlow = CALayer()

    private let axis: LUMSignalAxis
    private let trackHeight: CGFloat = 8
    private let thumbSize: CGFloat = 28

    /// Current value, clamped to 0...100. Setting it updates the UI without
    /// firing `.valueChanged` (that's reserved for user interaction).
    var value: Int = 50 {
        didSet {
            value = min(max(value, 0), 100)
            setNeedsLayout()
        }
    }

    init(axis: LUMSignalAxis, value: Int = 50) {
        self.axis = axis
        super.init(frame: .zero)
        self.value = value
        configure()
    }

    required init?(coder: NSCoder) {
        self.axis = .emotion
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        let color = LUMPalette.color(for: axis)

        trackLayer.colors = [LUMPalette.surfaceRaised.cgColor,
                             LUMPalette.surfaceRaised.cgColor]
        trackLayer.startPoint = CGPoint(x: 0, y: 0.5)
        trackLayer.endPoint = CGPoint(x: 1, y: 0.5)
        trackLayer.cornerRadius = trackHeight / 2
        layer.addSublayer(trackLayer)

        filledLayer.backgroundColor = color.cgColor
        filledLayer.cornerRadius = trackHeight / 2
        layer.addSublayer(filledLayer)

        thumbGlow.backgroundColor = color.cgColor
        thumbGlow.shadowColor = color.cgColor
        thumbGlow.shadowRadius = 8
        thumbGlow.shadowOpacity = 0.9
        thumbGlow.shadowOffset = .zero
        layer.addSublayer(thumbGlow)

        thumbView.backgroundColor = .white
        thumbView.layer.borderWidth = 3
        thumbView.layer.borderColor = color.cgColor
        thumbView.isUserInteractionEnabled = false
        addSubview(thumbView)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: thumbSize + 8)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let midY = bounds.midY
        let usableWidth = bounds.width - thumbSize
        let fraction = CGFloat(value) / 100.0
        let thumbX = thumbSize / 2 + usableWidth * fraction

        trackLayer.frame = CGRect(x: thumbSize / 2, y: midY - trackHeight / 2,
                                  width: bounds.width - thumbSize, height: trackHeight)
        filledLayer.frame = CGRect(x: thumbSize / 2, y: midY - trackHeight / 2,
                                   width: usableWidth * fraction, height: trackHeight)

        let thumbFrame = CGRect(x: thumbX - thumbSize / 2, y: midY - thumbSize / 2,
                                width: thumbSize, height: thumbSize)
        // Disable implicit animation so the thumb tracks the finger crisply.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        thumbView.frame = thumbFrame
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbGlow.frame = thumbFrame
        thumbGlow.cornerRadius = thumbSize / 2
        CATransaction.commit()
    }

    // MARK: Interaction

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        updateValue(at: gesture.location(in: self).x)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        updateValue(at: gesture.location(in: self).x)
    }

    private func updateValue(at x: CGFloat) {
        let usableWidth = bounds.width - thumbSize
        guard usableWidth > 0 else { return }
        let clampedX = min(max(x - thumbSize / 2, 0), usableWidth)
        let newValue = Int((clampedX / usableWidth * 100).rounded())
        if newValue != value {
            value = newValue
            sendActions(for: .valueChanged)
        }
    }
}
