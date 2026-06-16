//
//  LUMStatisticsViewController.swift
//  LumenAtlas
//
//  Lifetime stats overview: headline tiles plus a per-axis mean/range table.
//

import UIKit

final class LUMStatisticsViewController: LUMBaseViewController {

    private let viewModel: LUMStatisticsViewModel

    init(viewModel: LUMStatisticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Statistics"
        let (_, content) = makeScrollContainer()

        // Headline tiles (2x2).
        let tiles = [
            ("Signals", "\(viewModel.totalEvents)"),
            ("Days", "\(viewModel.daysCovered)"),
            ("Tags", "\(viewModel.totalTags)"),
            ("Episodes", "\(viewModel.totalClusters)")
        ]
        let topRow = UIStackView(arrangedSubviews: [makeTile(tiles[0]), makeTile(tiles[1])])
        topRow.axis = .horizontal; topRow.spacing = 10; topRow.distribution = .fillEqually
        let bottomRow = UIStackView(arrangedSubviews: [makeTile(tiles[2]), makeTile(tiles[3])])
        bottomRow.axis = .horizontal; bottomRow.spacing = 10; bottomRow.distribution = .fillEqually
        content.addArrangedSubview(topRow)
        content.addArrangedSubview(bottomRow)

        // Consistency + active day.
        content.addArrangedSubview(makeWideCard(
            title: "Logging Consistency",
            value: "\(viewModel.consistency)%",
            subtitle: viewModel.mostActiveDay.map { "Most active on \($0)" } ?? "No data yet"))

        // Per-axis table.
        content.addArrangedSubview(makeSectionTitle("Signal Averages"))
        let tableCard = LUMGlassCardView()
        let tableStack = UIStackView()
        tableStack.axis = .vertical
        tableStack.spacing = 14
        tableStack.translatesAutoresizingMaskIntoConstraints = false
        for stat in viewModel.axisStats {
            tableStack.addArrangedSubview(makeAxisStatRow(stat))
        }
        if viewModel.axisStats.isEmpty {
            let empty = UILabel()
            empty.text = "Log some signals to see averages."
            empty.font = LUMFont.body(14)
            empty.textColor = LUMPalette.textSecondary
            tableStack.addArrangedSubview(empty)
        }
        tableCard.contentView.addSubview(tableStack)
        NSLayoutConstraint.activate([
            tableStack.topAnchor.constraint(equalTo: tableCard.contentView.topAnchor),
            tableStack.bottomAnchor.constraint(equalTo: tableCard.contentView.bottomAnchor),
            tableStack.leadingAnchor.constraint(equalTo: tableCard.contentView.leadingAnchor),
            tableStack.trailingAnchor.constraint(equalTo: tableCard.contentView.trailingAnchor)
        ])
        content.addArrangedSubview(tableCard)
    }

    private func makeTile(_ data: (String, String)) -> UIView {
        let card = LUMGlassCardView()
        let value = UILabel()
        value.text = data.1
        value.font = LUMFont.mono(30)
        value.textColor = LUMPalette.textPrimary
        let caption = UILabel()
        caption.text = data.0.uppercased()
        caption.font = LUMFont.caption(11)
        caption.textColor = LUMPalette.textSecondary
        let stack = UIStackView(arrangedSubviews: [value, caption])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
        return card
    }

    private func makeWideCard(title: String, value: String, subtitle: String) -> UIView {
        let card = LUMGlassCardView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = LUMFont.caption(13)
        titleLabel.textColor = LUMPalette.textSecondary
        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = LUMFont.mono(28)
        valueLabel.textColor = LUMPalette.neonCyan
        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = LUMFont.caption(12)
        subtitleLabel.textColor = LUMPalette.textMuted
        let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 2
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
        return card
    }

    private func makeAxisStatRow(_ stat: LUMStatisticsViewModel.AxisStat) -> UIView {
        let color = LUMPalette.color(for: stat.axis)
        let name = UILabel()
        name.text = "\(stat.axis.glyph)  \(stat.axis.title)"
        name.font = LUMFont.body(15)
        name.textColor = color

        let detail = UILabel()
        detail.text = "avg \(stat.mean) · \(stat.min)–\(stat.max)"
        detail.font = LUMFont.mono(13)
        detail.textColor = LUMPalette.textPrimary
        detail.textAlignment = .right

        let row = UIStackView(arrangedSubviews: [name, UIView(), detail])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = LUMFont.heading(17)
        label.textColor = LUMPalette.textPrimary
        return label
    }
}
