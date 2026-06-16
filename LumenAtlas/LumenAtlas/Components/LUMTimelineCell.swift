//
//  LUMTimelineCell.swift
//  LumenAtlas
//
//  Timeline row: a glass card showing the event title, time, a composite mood
//  bar and compact per-axis chips. Pure presentation — configured from a small
//  view-state struct so the cell knows nothing about the model layer.
//

import UIKit

/// Minimal data the cell needs, decoupled from LUMEvent so the same cell can be
/// reused in search results and detail previews.
struct LUMTimelineCellState {
    let title: String
    let timeText: String
    let composite: Int
    let axisValues: [(axis: LUMSignalAxis, value: Int)]
    let tags: [String]
}

final class LUMTimelineCell: UITableViewCell {

    static let reuseID = "LUMTimelineCell"

    private let card = LUMGlassCardView()
    private let titleLabel = UILabel()
    private let timeLabel = UILabel()
    private let moodBar = UIView()
    private let moodFill = UIView()
    private let chipsStack = UIStackView()
    private var moodFillWidth: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        titleLabel.font = LUMFont.heading(17)
        titleLabel.textColor = LUMPalette.textPrimary
        titleLabel.numberOfLines = 1

        timeLabel.font = LUMFont.caption(12)
        timeLabel.textColor = LUMPalette.textSecondary

        moodBar.backgroundColor = LUMPalette.surfaceRaised
        moodBar.layer.cornerRadius = 3
        moodBar.translatesAutoresizingMaskIntoConstraints = false
        moodFill.layer.cornerRadius = 3
        moodFill.translatesAutoresizingMaskIntoConstraints = false
        moodBar.addSubview(moodFill)

        chipsStack.axis = .horizontal
        chipsStack.spacing = 6
        chipsStack.distribution = .fillProportionally

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, timeLabel])
        headerStack.axis = .horizontal
        headerStack.alignment = .firstBaseline
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [headerStack, moodBar, chipsStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)

        moodFillWidth = moodFill.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: LUMMetrics.screenInset),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -LUMMetrics.screenInset),

            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),

            moodBar.heightAnchor.constraint(equalToConstant: 6),
            moodFill.topAnchor.constraint(equalTo: moodBar.topAnchor),
            moodFill.bottomAnchor.constraint(equalTo: moodBar.bottomAnchor),
            moodFill.leadingAnchor.constraint(equalTo: moodBar.leadingAnchor),
            moodFillWidth
        ])
    }

    func configure(with state: LUMTimelineCellState) {
        titleLabel.text = state.title
        timeLabel.text = state.timeText

        let color = LUMPalette.moodColor(Double(state.composite))
        moodFill.backgroundColor = color

        chipsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for entry in state.axisValues {
            chipsStack.addArrangedSubview(makeChip(axis: entry.axis, value: entry.value))
        }

        // Update the mood fill width relative to the bar once laid out.
        layoutIfNeeded()
        moodFillWidth.constant = moodBar.bounds.width * CGFloat(state.composite) / 100.0
        UIView.animate(withDuration: 0.4) { self.layoutIfNeeded() }
    }

    private func makeChip(axis: LUMSignalAxis, value: Int) -> UIView {
        let label = UILabel()
        label.font = LUMFont.caption(11)
        label.textColor = LUMPalette.color(for: axis)
        label.text = "\(axis.glyph) \(value)"
        let container = UIView()
        container.backgroundColor = LUMPalette.color(for: axis).withAlphaComponent(0.12)
        container.layer.cornerRadius = 8
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        return container
    }
}
