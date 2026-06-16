//
//  LUMBaseViewController.swift
//  LumenAtlas
//
//  Common scaffolding for every screen: the deep neon-gradient background and a
//  couple of layout helpers. Keeps each feature VC focused on its own content.
//

import UIKit

class LUMBaseViewController: UIViewController {

    private let gradientLayer = CAGradientLayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = LUMPalette.background
        installGradient()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    /// A subtle radial-ish vertical gradient that gives the dark background
    /// depth without competing with foreground neon.
    private func installGradient() {
        gradientLayer.colors = [
            LUMPalette.background.cgColor,
            LUMPalette.surface.withAlphaComponent(0.6).cgColor,
            LUMPalette.background.cgColor
        ]
        gradientLayer.locations = [0.0, 0.45, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    /// Standard scroll container used by the content-heavy screens.
    func makeScrollContainer() -> (scroll: UIScrollView, content: UIStackView) {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)

        let content = UIStackView()
        content.axis = .vertical
        content.spacing = LUMMetrics.spacing
        content.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(content)

        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor,
                                             constant: LUMMetrics.screenInset),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor,
                                              constant: -LUMMetrics.screenInset)
        ])
        return (scroll, content)
    }
}
