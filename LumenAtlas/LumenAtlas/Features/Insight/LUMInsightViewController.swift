//
//  LUMInsightViewController.swift
//  LumenAtlas
//
//  Presents the synthesised insights as a stack of toned glass cards.
//

import UIKit

final class LUMInsightViewController: LUMBaseViewController {

    private let viewModel: LUMInsightViewModel

    init(viewModel: LUMInsightViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Insight Engine"
        let (_, content) = makeScrollContainer()

        let intro = UILabel()
        intro.text = "Patterns synthesised from your signals. These are computed, not stored — they update as you log."
        intro.font = LUMFont.body(14)
        intro.textColor = LUMPalette.textSecondary
        intro.numberOfLines = 0
        content.addArrangedSubview(intro)

        for insight in viewModel.generate() {
            content.addArrangedSubview(makeInsightCard(insight))
        }
    }

    private func makeInsightCard(_ insight: LUMInsightViewModel.Insight) -> UIView {
        let card = LUMGlassCardView()
        let accent: UIColor
        switch insight.tone {
        case .positive: accent = LUMPalette.neonCyan
        case .caution:  accent = LUMPalette.color(for: .stress)
        case .neutral:  accent = LUMPalette.neonBlue
        }

        let icon = UIImageView(image: UIImage(systemName: insight.icon))
        icon.tintColor = accent
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 26).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 26).isActive = true

        let headline = UILabel()
        headline.text = insight.headline
        headline.font = LUMFont.heading(16)
        headline.textColor = LUMPalette.textPrimary
        headline.numberOfLines = 0

        let detail = UILabel()
        detail.text = insight.detail
        detail.font = LUMFont.body(14)
        detail.textColor = LUMPalette.textSecondary
        detail.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [headline, detail])
        textStack.axis = .vertical
        textStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [icon, textStack])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .top
        row.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            row.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            row.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
        return card
    }
}
