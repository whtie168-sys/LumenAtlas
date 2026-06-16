//
//  LUMAboutViewController.swift
//  LumenAtlas
//
//  About screen: what the app is, how the analysis works, and the privacy
//  stance. Plain informational content, themed to match.
//

import UIKit

final class LUMAboutViewController: LUMBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"
        let (_, content) = makeScrollContainer()

        content.addArrangedSubview(makeHeader())
        content.addArrangedSubview(makeParagraphCard(
            title: "What is Lumen Atlas?",
            body: "Lumen Atlas is a personal signal-mapping system. Instead of free-form journaling, you capture moments as structured readings across four life signals — emotion, energy, stress and focus — and the app turns that stream into trends, anomalies and relationships."))

        content.addArrangedSubview(makeParagraphCard(
            title: "How the analysis works",
            body: "Every screen is computed from your data: 7-day rolling averages smooth the noise, a z-score detector flags spikes and peaks, a time-window pass groups events into episodes, and a co-occurrence model links your tags into a relationship graph weighted by how often and how closely they appear together."))

        content.addArrangedSubview(makeParagraphCard(
            title: "Your data stays yours",
            body: "Everything is stored locally on this device. The app makes no network requests and has no account or cloud. You can lock it behind a PIN, and export or delete your data at any time."))

        let version = UILabel()
        version.text = "Version 1.0 · Built with UIKit"
        version.font = LUMFont.caption(12)
        version.textColor = LUMPalette.textMuted
        version.textAlignment = .center
        content.addArrangedSubview(version)
    }

    private func makeHeader() -> UIView {
        let container = UIView()
        let title = UILabel()
        title.text = "LUMEN ATLAS"
        title.font = LUMFont.title(28)
        title.textColor = LUMPalette.textPrimary
        title.textAlignment = .center
        let subtitle = UILabel()
        subtitle.text = "Personal Signal Mapping"
        subtitle.font = LUMFont.body(15)
        subtitle.textColor = LUMPalette.neonBlue
        subtitle.textAlignment = .center
        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }

    private func makeParagraphCard(title: String, body: String) -> UIView {
        let card = LUMGlassCardView()
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = LUMFont.heading(17)
        titleLabel.textColor = LUMPalette.textPrimary
        titleLabel.numberOfLines = 0
        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = LUMFont.body(14)
        bodyLabel.textColor = LUMPalette.textSecondary
        bodyLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 8
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
}
