//
//  LUMBarChartView.swift
//  LumenAtlas
//
//  Vertical bar chart for distributions and tag rankings. Each bar grows in
//  with a staggered spring and carries an optional caption beneath. Like the
//  line chart, it is self-contained and reads only plain value/label pairs.
//

import UIKit

final class LUMBarChartView: UIView {

    struct Bar {
        let value: Double
        let label: String
        let color: UIColor
    }

    private var bars: [Bar] = []
    private var barLayers: [CALayer] = []
    private let labelStack = UIStackView()

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
        labelStack.axis = .horizontal
        labelStack.distribution = .fillEqually
        labelStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(labelStack)
        NSLayoutConstraint.activate([
            labelStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            labelStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelStack.bottomAnchor.constraint(equalTo: bottomAnchor),
            labelStack.heightAnchor.constraint(equalToConstant: 16)
        ])
    }

    func update(bars: [Bar]) {
        self.bars = bars
        barLayers.forEach { $0.removeFromSuperlayer() }
        barLayers.removeAll()
        labelStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for bar in bars {
            let layer = CALayer()
            layer.backgroundColor = bar.color.cgColor
            layer.cornerRadius = 4
            self.layer.addSublayer(layer)
            barLayers.append(layer)

            let label = UILabel()
            label.text = bar.label
            label.font = LUMFont.caption(10)
            label.textColor = LUMPalette.textSecondary
            label.textAlignment = .center
            labelStack.addArrangedSubview(label)
        }
        setNeedsLayout()
        layoutIfNeeded()
        animateBars()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard !bars.isEmpty else { return }

        let maxValue = max(1, bars.map(\.value).max() ?? 1)
        let plotHeight = bounds.height - 22
        let slot = bounds.width / CGFloat(bars.count)
        let barWidth = slot * 0.55

        for (index, bar) in bars.enumerated() {
            let height = plotHeight * CGFloat(bar.value / maxValue)
            let x = slot * CGFloat(index) + (slot - barWidth) / 2
            barLayers[index].frame = CGRect(x: x, y: plotHeight - height,
                                            width: barWidth, height: max(2, height))
        }
    }

    private func animateBars() {
        for (index, layer) in barLayers.enumerated() {
            let anim = CABasicAnimation(keyPath: "transform.scale.y")
            anim.fromValue = 0
            anim.toValue = 1
            anim.duration = 0.5
            anim.beginTime = CACurrentMediaTime() + Double(index) * 0.04
            anim.fillMode = .backwards
            anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
            // Anchor the scale at the bottom of the bar.
            layer.anchorPoint = CGPoint(x: 0.5, y: 1.0)
            layer.add(anim, forKey: "grow")
        }
    }
}
