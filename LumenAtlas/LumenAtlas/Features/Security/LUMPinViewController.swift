//
//  LUMPinViewController.swift
//  LumenAtlas
//
//  PIN entry: a row of glowing dots, a custom numeric keypad and a shake on
//  failure. Drives all three PIN modes via the view model.
//

import UIKit

final class LUMPinViewController: LUMBaseViewController {

    /// Called when the flow completes successfully (unlock / set / disable).
    var onUnlocked: (() -> Void)?

    private let viewModel: LUMPinViewModel
    private let promptLabel = UILabel()
    private let dotsStack = UIStackView()
    private var dots: [UIView] = []
    private var entry: String = "" { didSet { updateDots() } }

    init(viewModel: LUMPinViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Privacy"
        buildLayout()
        refreshPrompt()
    }

    private func buildLayout() {
        promptLabel.font = LUMFont.heading(20)
        promptLabel.textColor = LUMPalette.textPrimary
        promptLabel.textAlignment = .center
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(promptLabel)

        dotsStack.axis = .horizontal
        dotsStack.spacing = 18
        dotsStack.alignment = .center
        dotsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotsStack)
        for _ in 0..<viewModel.pinLength {
            let dot = UIView()
            dot.layer.cornerRadius = 8
            dot.layer.borderWidth = 1.5
            dot.layer.borderColor = LUMPalette.neonBlue.cgColor
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 16).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 16).isActive = true
            dots.append(dot)
            dotsStack.addArrangedSubview(dot)
        }

        let keypad = makeKeypad()
        keypad.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(keypad)

        NSLayoutConstraint.activate([
            promptLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            promptLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            dotsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dotsStack.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 40),
            keypad.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            keypad.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            keypad.widthAnchor.constraint(equalToConstant: 260)
        ])
    }

    private func makeKeypad() -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 16
        grid.distribution = .fillEqually

        let rows = [["1", "2", "3"], ["4", "5", "6"], ["7", "8", "9"], ["", "0", "⌫"]]
        for row in rows {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 16
            rowStack.distribution = .fillEqually
            for key in row {
                rowStack.addArrangedSubview(makeKey(key))
            }
            grid.addArrangedSubview(rowStack)
        }
        return grid
    }

    private func makeKey(_ symbol: String) -> UIView {
        let button = UIButton(type: .custom)
        guard !symbol.isEmpty else { return button } // spacer

        button.setTitle(symbol, for: .normal)
        button.titleLabel?.font = LUMFont.title(24)
        button.setTitleColor(LUMPalette.textPrimary, for: .normal)
        button.backgroundColor = LUMPalette.surface.withAlphaComponent(0.6)
        button.layer.cornerRadius = 38
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 76).isActive = true
        button.addAction(UIAction { [weak self] _ in self?.handleKey(symbol) }, for: .touchUpInside)
        return button
    }

    // MARK: Input

    private func handleKey(_ symbol: String) {
        if symbol == "⌫" {
            if !entry.isEmpty { entry.removeLast() }
            return
        }
        guard entry.count < viewModel.pinLength else { return }
        entry.append(symbol)

        if entry.count == viewModel.pinLength {
            // Defer slightly so the final dot fills before we react.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
                self?.submit()
            }
        }
    }

    private func submit() {
        let outcome = viewModel.submit(entry)
        switch outcome {
        case .success:
            onUnlocked?()
        case .advance:
            entry = ""
            refreshPrompt()
        case .mismatch, .wrong:
            shake()
            entry = ""
            refreshPrompt()
        }
    }

    private func refreshPrompt() {
        promptLabel.text = viewModel.prompt
    }

    private func updateDots() {
        for (index, dot) in dots.enumerated() {
            let filled = index < entry.count
            UIView.animate(withDuration: 0.15) {
                dot.backgroundColor = filled ? LUMPalette.neonBlue : .clear
                dot.transform = filled ? CGAffineTransform(scaleX: 1.2, y: 1.2) : .identity
            }
        }
    }

    private func shake() {
        let anim = CAKeyframeAnimation(keyPath: "position.x")
        anim.values = [0, -12, 12, -8, 8, 0]
        anim.keyTimes = [0, 0.2, 0.4, 0.6, 0.8, 1]
        anim.duration = 0.4
        anim.isAdditive = true
        dotsStack.layer.add(anim, forKey: "shake")
    }
}
