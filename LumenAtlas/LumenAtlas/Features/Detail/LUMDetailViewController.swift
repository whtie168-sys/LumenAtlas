//
//  LUMDetailViewController.swift
//  LumenAtlas
//
//  Event detail: composite dial, per-axis bars, a contextual insight line,
//  tags, note, and edit/delete actions.
//

import UIKit

final class LUMDetailViewController: LUMBaseViewController {

    var onEdit: ((LUMEvent) -> Void)?

    private let viewModel: LUMDetailViewModel
    private var content: UIStackView!

    init(viewModel: LUMDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Detail"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain, target: self, action: #selector(editTapped))
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.refresh()
        rebuild()
    }

    private func build() {
        let (_, content) = makeScrollContainer()
        self.content = content
        rebuild()
    }

    private func rebuild() {
        guard content != nil else { return }
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Header: title + date.
        let titleLabel = UILabel()
        titleLabel.text = viewModel.title
        titleLabel.font = LUMFont.title(26)
        titleLabel.textColor = LUMPalette.textPrimary
        titleLabel.numberOfLines = 0
        let dateLabel = UILabel()
        dateLabel.text = viewModel.dateText
        dateLabel.font = LUMFont.caption(13)
        dateLabel.textColor = LUMPalette.textSecondary
        let header = UIStackView(arrangedSubviews: [titleLabel, dateLabel])
        header.axis = .vertical
        header.spacing = 4
        content.addArrangedSubview(header)

        // Composite dial.
        let dialCard = LUMGlassCardView()
        let dial = LUMEnergyDial(caption: "Composite", tint: LUMPalette.neonPurple)
        dial.translatesAutoresizingMaskIntoConstraints = false
        dialCard.contentView.addSubview(dial)
        NSLayoutConstraint.activate([
            dial.topAnchor.constraint(equalTo: dialCard.contentView.topAnchor, constant: 4),
            dial.bottomAnchor.constraint(equalTo: dialCard.contentView.bottomAnchor, constant: -4),
            dial.centerXAnchor.constraint(equalTo: dialCard.contentView.centerXAnchor),
            dial.widthAnchor.constraint(equalToConstant: 130),
            dial.heightAnchor.constraint(equalToConstant: 130)
        ])
        content.addArrangedSubview(dialCard)
        dial.setValue(viewModel.composite, animated: true)

        // Per-axis bars.
        let axisCard = LUMGlassCardView()
        let axisStack = UIStackView()
        axisStack.axis = .vertical
        axisStack.spacing = 12
        axisStack.translatesAutoresizingMaskIntoConstraints = false
        for entry in viewModel.axisBreakdown {
            axisStack.addArrangedSubview(makeAxisBar(axis: entry.axis, value: entry.value))
        }
        axisCard.contentView.addSubview(axisStack)
        NSLayoutConstraint.activate([
            axisStack.topAnchor.constraint(equalTo: axisCard.contentView.topAnchor),
            axisStack.bottomAnchor.constraint(equalTo: axisCard.contentView.bottomAnchor),
            axisStack.leadingAnchor.constraint(equalTo: axisCard.contentView.leadingAnchor),
            axisStack.trailingAnchor.constraint(equalTo: axisCard.contentView.trailingAnchor)
        ])
        content.addArrangedSubview(axisCard)

        // Contextual insight.
        let insightCard = LUMGlassCardView()
        let insight = UILabel()
        insight.text = "✦ " + viewModel.contextualInsight
        insight.font = LUMFont.body(15)
        insight.textColor = LUMPalette.neonCyan
        insight.numberOfLines = 0
        insight.translatesAutoresizingMaskIntoConstraints = false
        insightCard.contentView.addSubview(insight)
        NSLayoutConstraint.activate([
            insight.topAnchor.constraint(equalTo: insightCard.contentView.topAnchor),
            insight.bottomAnchor.constraint(equalTo: insightCard.contentView.bottomAnchor),
            insight.leadingAnchor.constraint(equalTo: insightCard.contentView.leadingAnchor),
            insight.trailingAnchor.constraint(equalTo: insightCard.contentView.trailingAnchor)
        ])
        content.addArrangedSubview(insightCard)

        // Tags.
        if !viewModel.tags.isEmpty {
            let tagCard = LUMGlassCardView()
            let flow = UIStackView()
            flow.axis = .horizontal
            flow.spacing = 8
            flow.translatesAutoresizingMaskIntoConstraints = false
            for tag in viewModel.tags { flow.addArrangedSubview(makeTagPill(tag)) }
            flow.addArrangedSubview(UIView())
            tagCard.contentView.addSubview(flow)
            NSLayoutConstraint.activate([
                flow.topAnchor.constraint(equalTo: tagCard.contentView.topAnchor),
                flow.bottomAnchor.constraint(equalTo: tagCard.contentView.bottomAnchor),
                flow.leadingAnchor.constraint(equalTo: tagCard.contentView.leadingAnchor),
                flow.trailingAnchor.constraint(equalTo: tagCard.contentView.trailingAnchor)
            ])
            content.addArrangedSubview(tagCard)
        }

        // Note.
        if !viewModel.note.isEmpty {
            let noteCard = LUMGlassCardView()
            let note = UILabel()
            note.text = viewModel.note
            note.font = LUMFont.body(15)
            note.textColor = LUMPalette.textPrimary
            note.numberOfLines = 0
            note.translatesAutoresizingMaskIntoConstraints = false
            noteCard.contentView.addSubview(note)
            NSLayoutConstraint.activate([
                note.topAnchor.constraint(equalTo: noteCard.contentView.topAnchor),
                note.bottomAnchor.constraint(equalTo: noteCard.contentView.bottomAnchor),
                note.leadingAnchor.constraint(equalTo: noteCard.contentView.leadingAnchor),
                note.trailingAnchor.constraint(equalTo: noteCard.contentView.trailingAnchor)
            ])
            content.addArrangedSubview(noteCard)
        }

        // Delete.
        let deleteButton = LUMNeonButton(title: "Delete Signal", style: .outline)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        content.addArrangedSubview(deleteButton)
    }

    private func makeAxisBar(axis: LUMSignalAxis, value: Int) -> UIView {
        let color = LUMPalette.color(for: axis)
        let label = UILabel()
        label.text = "\(axis.glyph)  \(axis.title)"
        label.font = LUMFont.caption(13)
        label.textColor = color
        let valueLabel = UILabel()
        valueLabel.text = "\(value)"
        valueLabel.font = LUMFont.mono(14)
        valueLabel.textColor = LUMPalette.textPrimary
        valueLabel.textAlignment = .right
        let headerRow = UIStackView(arrangedSubviews: [label, valueLabel])
        headerRow.axis = .horizontal

        let track = UIView()
        track.backgroundColor = LUMPalette.surfaceRaised
        track.layer.cornerRadius = 4
        track.translatesAutoresizingMaskIntoConstraints = false
        let fill = UIView()
        fill.backgroundColor = color
        fill.layer.cornerRadius = 4
        fill.translatesAutoresizingMaskIntoConstraints = false
        track.addSubview(fill)
        NSLayoutConstraint.activate([
            track.heightAnchor.constraint(equalToConstant: 8),
            fill.leadingAnchor.constraint(equalTo: track.leadingAnchor),
            fill.topAnchor.constraint(equalTo: track.topAnchor),
            fill.bottomAnchor.constraint(equalTo: track.bottomAnchor),
            fill.widthAnchor.constraint(equalTo: track.widthAnchor, multiplier: CGFloat(value) / 100.0)
        ])

        let column = UIStackView(arrangedSubviews: [headerRow, track])
        column.axis = .vertical
        column.spacing = 6
        return column
    }

    private func makeTagPill(_ tag: String) -> UIView {
        let label = UILabel()
        label.text = "#\(tag)"
        label.font = LUMFont.caption(13)
        label.textColor = LUMPalette.neonBlue
        let container = UIView()
        container.backgroundColor = LUMPalette.neonBlue.withAlphaComponent(0.12)
        container.layer.cornerRadius = 12
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        return container
    }

    @objc private func editTapped() { onEdit?(viewModel.event) }

    @objc private func deleteTapped() {
        let alert = UIAlertController(title: "Delete this signal?",
                                      message: "This cannot be undone.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.viewModel.delete()
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
