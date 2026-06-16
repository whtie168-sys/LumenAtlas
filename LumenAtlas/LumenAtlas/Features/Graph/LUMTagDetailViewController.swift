//
//  LUMTagDetailViewController.swift
//  LumenAtlas
//
//  Tag drill-down: average mood, related tags as tappable chips, and the list
//  of events carrying the tag.
//

import UIKit

final class LUMTagDetailViewController: LUMBaseViewController {

    var onSelectEvent: ((LUMEvent) -> Void)?

    private let viewModel: LUMTagDetailViewModel
    private var content: UIStackView!

    init(viewModel: LUMTagDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "#\(viewModel.tag)"
        build()
    }

    private func build() {
        let (_, content) = makeScrollContainer()
        self.content = content

        // Mood summary.
        let summaryCard = LUMGlassCardView()
        let moodLabel = UILabel()
        moodLabel.font = LUMFont.mono(34)
        moodLabel.textColor = LUMPalette.moodColor(Double(viewModel.averageMood))
        moodLabel.text = "\(viewModel.averageMood)"
        let caption = UILabel()
        caption.font = LUMFont.caption(13)
        caption.textColor = LUMPalette.textSecondary
        caption.text = "average composite across \(viewModel.events.count) events"
        let summaryStack = UIStackView(arrangedSubviews: [moodLabel, caption])
        summaryStack.axis = .vertical
        summaryStack.spacing = 2
        summaryStack.translatesAutoresizingMaskIntoConstraints = false
        summaryCard.contentView.addSubview(summaryStack)
        NSLayoutConstraint.activate([
            summaryStack.topAnchor.constraint(equalTo: summaryCard.contentView.topAnchor),
            summaryStack.bottomAnchor.constraint(equalTo: summaryCard.contentView.bottomAnchor),
            summaryStack.leadingAnchor.constraint(equalTo: summaryCard.contentView.leadingAnchor),
            summaryStack.trailingAnchor.constraint(equalTo: summaryCard.contentView.trailingAnchor)
        ])
        content.addArrangedSubview(summaryCard)

        // Related tags.
        let related = viewModel.relatedTags
        if !related.isEmpty {
            content.addArrangedSubview(makeSectionTitle("Related Tags"))
            for relation in related.prefix(6) {
                content.addArrangedSubview(makeRelatedRow(relation))
            }
        }

        // Events.
        content.addArrangedSubview(makeSectionTitle("Events"))
        for event in viewModel.events {
            content.addArrangedSubview(makeEventRow(event))
        }
    }

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = LUMFont.heading(17)
        label.textColor = LUMPalette.textPrimary
        return label
    }

    private func makeRelatedRow(_ relation: LUMTagDetailViewModel.RelatedTag) -> UIView {
        let card = LUMGlassCardView()
        let name = UILabel()
        name.text = "#\(relation.tag)"
        name.font = LUMFont.body(15)
        name.textColor = LUMPalette.neonBlue

        let strengthBar = UIView()
        strengthBar.backgroundColor = LUMPalette.surfaceRaised
        strengthBar.layer.cornerRadius = 3
        strengthBar.translatesAutoresizingMaskIntoConstraints = false
        let fill = UIView()
        fill.backgroundColor = LUMPalette.neonPurple
        fill.layer.cornerRadius = 3
        fill.translatesAutoresizingMaskIntoConstraints = false
        strengthBar.addSubview(fill)

        let count = UILabel()
        count.text = "×\(relation.coOccurrence)"
        count.font = LUMFont.caption(12)
        count.textColor = LUMPalette.textSecondary

        let stack = UIStackView(arrangedSubviews: [name, strengthBar, count])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            strengthBar.heightAnchor.constraint(equalToConstant: 6),
            strengthBar.widthAnchor.constraint(equalToConstant: 90),
            fill.leadingAnchor.constraint(equalTo: strengthBar.leadingAnchor),
            fill.topAnchor.constraint(equalTo: strengthBar.topAnchor),
            fill.bottomAnchor.constraint(equalTo: strengthBar.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: strengthBar.widthAnchor,
                                        multiplier: max(0.05, CGFloat(relation.strength)))
        ])

        card.addAction(LUMTapAction { [weak self] in
            // Selecting a related tag opens its first event for quick traversal.
            if let event = self?.eventForTag(relation.tag) { self?.onSelectEvent?(event) }
        })
        return card
    }

    private func eventForTag(_ tag: String) -> LUMEvent? {
        viewModel.events.first { $0.tags.contains(tag) }
    }

    private func makeEventRow(_ event: LUMEvent) -> UIView {
        let card = LUMGlassCardView()
        let dot = UIView()
        dot.backgroundColor = LUMPalette.moodColor(Double(event.compositeScore))
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let title = UILabel()
        title.text = event.title
        title.font = LUMFont.body(15)
        title.textColor = LUMPalette.textPrimary

        let stack = UIStackView(arrangedSubviews: [dot, title, UIView()])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
        card.addAction(LUMTapAction { [weak self] in self?.onSelectEvent?(event) })
        return card
    }
}
