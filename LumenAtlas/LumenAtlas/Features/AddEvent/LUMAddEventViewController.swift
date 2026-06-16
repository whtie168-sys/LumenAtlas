//
//  LUMAddEventViewController.swift
//  LumenAtlas
//
//  The capture form. A title field, four custom signal sliders with a live
//  composite preview, a tag field and a note. Commits through the view model
//  and dismisses on save.
//

import UIKit

final class LUMAddEventViewController: LUMBaseViewController {

    var onFinished: (() -> Void)?

    private let viewModel: LUMAddEventViewModel
    private let titleField = UITextField()
    private let tagField = UITextField()
    private let noteView = UITextView()
    private let previewDial = LUMEnergyDial(caption: "Composite", tint: LUMPalette.neonPurple)
    private var sliders: [LUMSignalAxis: LUMEmotionSlider] = [:]
    private var saveButton: LUMNeonButton!

    init(viewModel: LUMAddEventViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.screenTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationController?.navigationBar.tintColor = LUMPalette.neonBlue
        buildLayout()
        updatePreview()
    }

    private func buildLayout() {
        let (_, content) = makeScrollContainer()

        // Title field.
        content.addArrangedSubview(makeFieldLabel("Title"))
        styleTextField(titleField, placeholder: "What happened?")
        titleField.text = viewModel.title
        titleField.addTarget(self, action: #selector(titleChanged), for: .editingChanged)
        content.addArrangedSubview(wrapInCard(titleField, height: 30))

        // Composite preview dial.
        let dialCard = LUMGlassCardView()
        previewDial.translatesAutoresizingMaskIntoConstraints = false
        dialCard.contentView.addSubview(previewDial)
        NSLayoutConstraint.activate([
            previewDial.topAnchor.constraint(equalTo: dialCard.contentView.topAnchor, constant: 4),
            previewDial.bottomAnchor.constraint(equalTo: dialCard.contentView.bottomAnchor, constant: -4),
            previewDial.centerXAnchor.constraint(equalTo: dialCard.contentView.centerXAnchor),
            previewDial.widthAnchor.constraint(equalToConstant: 120),
            previewDial.heightAnchor.constraint(equalToConstant: 120)
        ])
        content.addArrangedSubview(dialCard)

        // Signal sliders.
        content.addArrangedSubview(makeFieldLabel("Signals"))
        let sliderCard = LUMGlassCardView()
        let sliderStack = UIStackView()
        sliderStack.axis = .vertical
        sliderStack.spacing = 18
        sliderStack.translatesAutoresizingMaskIntoConstraints = false
        for axis in LUMSignalAxis.allCases {
            let row = makeSliderRow(for: axis)
            sliderStack.addArrangedSubview(row)
        }
        sliderCard.contentView.addSubview(sliderStack)
        NSLayoutConstraint.activate([
            sliderStack.topAnchor.constraint(equalTo: sliderCard.contentView.topAnchor),
            sliderStack.bottomAnchor.constraint(equalTo: sliderCard.contentView.bottomAnchor),
            sliderStack.leadingAnchor.constraint(equalTo: sliderCard.contentView.leadingAnchor),
            sliderStack.trailingAnchor.constraint(equalTo: sliderCard.contentView.trailingAnchor)
        ])
        content.addArrangedSubview(sliderCard)

        // Tags.
        content.addArrangedSubview(makeFieldLabel("Tags (comma separated)"))
        styleTextField(tagField, placeholder: "work, health, calm")
        tagField.text = viewModel.tagsText
        tagField.autocapitalizationType = .none
        tagField.addTarget(self, action: #selector(tagsChanged), for: .editingChanged)
        content.addArrangedSubview(wrapInCard(tagField, height: 30))

        // Note.
        content.addArrangedSubview(makeFieldLabel("Note"))
        noteView.backgroundColor = .clear
        noteView.font = LUMFont.body(15)
        noteView.textColor = LUMPalette.textPrimary
        noteView.text = viewModel.note
        noteView.delegate = self
        noteView.translatesAutoresizingMaskIntoConstraints = false
        noteView.isScrollEnabled = false
        let noteCard = wrapInCard(noteView, height: 80)
        content.addArrangedSubview(noteCard)

        // Save.
        saveButton = LUMNeonButton(title: "Save Signal")
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        content.addArrangedSubview(saveButton)

        refreshSaveState()
    }

    // MARK: Builders

    private func makeSliderRow(for axis: LUMSignalAxis) -> UIView {
        let header = UILabel()
        header.font = LUMFont.caption(13)
        header.textColor = LUMPalette.color(for: axis)
        let valueLabel = UILabel()
        valueLabel.font = LUMFont.mono(15)
        valueLabel.textColor = LUMPalette.textPrimary
        valueLabel.textAlignment = .right

        let slider = LUMEmotionSlider(axis: axis, value: viewModel.value(for: axis))
        slider.translatesAutoresizingMaskIntoConstraints = false
        sliders[axis] = slider

        func sync() {
            header.text = "\(axis.glyph)  \(axis.title)"
            valueLabel.text = "\(slider.value)"
        }
        sync()
        slider.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.viewModel.setValue(slider.value, for: axis)
            sync()
            self.updatePreview()
        }, for: .valueChanged)

        let headerRow = UIStackView(arrangedSubviews: [header, valueLabel])
        headerRow.axis = .horizontal

        let column = UIStackView(arrangedSubviews: [headerRow, slider])
        column.axis = .vertical
        column.spacing = 4
        return column
    }

    private func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = LUMFont.caption(13)
        label.textColor = LUMPalette.textSecondary
        return label
    }

    private func styleTextField(_ field: UITextField, placeholder: String) {
        field.font = LUMFont.body(16)
        field.textColor = LUMPalette.textPrimary
        field.tintColor = LUMPalette.neonBlue
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: LUMPalette.textMuted])
    }

    private func wrapInCard(_ view: UIView, height: CGFloat) -> UIView {
        let card = LUMGlassCardView()
        view.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: height)
        ])
        return card
    }

    // MARK: Actions

    @objc private func titleChanged() {
        viewModel.title = titleField.text ?? ""
        refreshSaveState()
    }

    @objc private func tagsChanged() {
        viewModel.tagsText = tagField.text ?? ""
    }

    private func updatePreview() {
        // Mirror the model's composite formula for an instant preview.
        let positive = Double(viewModel.emotion + viewModel.energy + viewModel.focus) / 3.0
        let drag = Double(viewModel.stress) * 0.5
        let composite = Int((positive - drag + 50).clampedToSignalRange)
        previewDial.setValue(composite, animated: true)
    }

    private func refreshSaveState() {
        saveButton.isEnabled = viewModel.canSave
        saveButton.alpha = viewModel.canSave ? 1.0 : 0.4
    }

    @objc private func saveTapped() {
        view.endEditing(true)
        guard viewModel.save() != nil else { return }
        onFinished?()
    }

    @objc private func cancelTapped() {
        view.endEditing(true)
        dismiss(animated: true)
    }
}

extension LUMAddEventViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.note = textView.text
    }
}
