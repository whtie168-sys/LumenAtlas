//
//  LUMSettingsViewController.swift
//  LumenAtlas
//
//  Settings hub: a header summary plus a list of glass rows routing to the
//  sub-screens. No UITableView needed at this scale — a stack reads cleaner.
//

import UIKit

final class LUMSettingsViewController: LUMBaseViewController {

    var onStatistics: (() -> Void)?
    var onManageTags: (() -> Void)?
    var onConfigurePIN: (() -> Void)?
    var onImportExport: (() -> Void)?
    var onAbout: (() -> Void)?

    private let viewModel: LUMSettingsViewModel
    private var content: UIStackView!

    init(viewModel: LUMSettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        build()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rebuildRows()
    }

    private func build() {
        let (_, content) = makeScrollContainer()
        self.content = content
        rebuildRows()
    }

    private func rebuildRows() {
        guard content != nil else { return }
        content.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for row in viewModel.rows() {
            content.addArrangedSubview(makeRow(row))
        }
    }

    private func makeRow(_ row: LUMSettingsViewModel.Row) -> UIView {
        let card = LUMGlassCardView()

        let icon = UIImageView(image: UIImage(systemName: row.icon))
        icon.tintColor = LUMPalette.neonBlue
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(equalToConstant: 24).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let title = UILabel()
        title.text = row.title
        title.font = LUMFont.body(16)
        title.textColor = LUMPalette.textPrimary

        let subtitle = UILabel()
        subtitle.text = row.subtitle
        subtitle.font = LUMFont.caption(12)
        subtitle.textColor = LUMPalette.textSecondary

        let textStack = UIStackView(arrangedSubviews: [title, subtitle])
        textStack.axis = .vertical
        textStack.spacing = 2

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = LUMPalette.textMuted
        chevron.contentMode = .scaleAspectFit

        let row1 = UIStackView(arrangedSubviews: [icon, textStack, UIView(), chevron])
        row1.axis = .horizontal
        row1.spacing = 14
        row1.alignment = .center
        row1.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(row1)
        NSLayoutConstraint.activate([
            row1.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            row1.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            row1.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            row1.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])

        card.addAction(LUMTapAction { [weak self] in self?.handle(row.action) })
        return card
    }

    private func handle(_ action: LUMSettingsViewModel.Action) {
        switch action {
        case .statistics:   onStatistics?()
        case .tags:         onManageTags?()
        case .pin:          onConfigurePIN?()
        case .importExport: onImportExport?()
        case .about:        onAbout?()
        }
    }
}
