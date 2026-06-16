//
//  LUMGraphViewController.swift
//  LumenAtlas
//
//  Renders the memory graph: edges drawn on a CAShapeLayer beneath animated
//  node views. Tapping a node opens the tag detail. Re-runs the layout whenever
//  the canvas resizes.
//

import UIKit

final class LUMGraphViewController: LUMBaseViewController {

    var onSelectTag: ((String) -> Void)?

    private let viewModel: LUMGraphViewModel
    private let canvas = UIView()
    private let edgeLayer = CAShapeLayer()
    private let legendLabel = UILabel()
    private let emptyLabel = UILabel()
    private var nodeViews: [LUMGraphNodeView] = []

    init(viewModel: LUMGraphViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Memory Graph"
        buildLayout()
        viewModel.onChange = { [weak self] in self?.scheduleRelayout() }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        edgeLayer.frame = canvas.bounds
        if canvas.bounds.size != .zero {
            viewModel.layout(in: canvas.bounds.size)
            renderGraph()
        }
    }

    private func buildLayout() {
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.backgroundColor = .clear
        canvas.layer.addSublayer(edgeLayer)
        edgeLayer.strokeColor = LUMPalette.neonBlue.withAlphaComponent(0.4).cgColor
        edgeLayer.fillColor = UIColor.clear.cgColor
        view.addSubview(canvas)

        legendLabel.font = LUMFont.caption(12)
        legendLabel.textColor = LUMPalette.textSecondary
        legendLabel.numberOfLines = 0
        legendLabel.text = "Nodes = tags · size = frequency · colour = mood · lines = co-occurrence"
        legendLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(legendLabel)

        emptyLabel.text = "The graph grows as you tag your signals.\nAdd a few events with shared tags."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = LUMFont.body(15)
        emptyLabel.textColor = LUMPalette.textSecondary
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvas.bottomAnchor.constraint(equalTo: legendLabel.topAnchor, constant: -8),

            legendLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LUMMetrics.screenInset),
            legendLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -LUMMetrics.screenInset),
            legendLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            emptyLabel.centerXAnchor.constraint(equalTo: canvas.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: canvas.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func scheduleRelayout() {
        guard canvas.bounds.size != .zero else { return }
        viewModel.layout(in: canvas.bounds.size)
        renderGraph()
    }

    private func renderGraph() {
        emptyLabel.isHidden = !viewModel.isEmpty

        // Clear previous node views.
        nodeViews.forEach { $0.removeFromSuperview() }
        nodeViews.removeAll()

        // Draw edges.
        let path = UIBezierPath()
        for edge in viewModel.edges {
            guard let a = viewModel.positioned[edge.source],
                  let b = viewModel.positioned[edge.target] else { continue }
            path.move(to: a.position)
            path.addLine(to: b.position)
        }
        edgeLayer.path = path.cgPath
        edgeLayer.lineWidth = 1.2

        // Place nodes.
        for (_, positioned) in viewModel.positioned {
            let nodeView = LUMGraphNodeView(node: positioned.node, radius: positioned.radius)
            nodeView.center = positioned.position
            canvas.addSubview(nodeView)
            nodeViews.append(nodeView)

            let tag = positioned.node.tag
            nodeView.addAction(LUMTapAction { [weak self] in self?.onSelectTag?(tag) })

            // Fade/scale in for a lively appearance.
            nodeView.alpha = 0
            nodeView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            UIView.animate(withDuration: 0.4,
                           delay: Double(abs(tag.hashValue) % 30) / 100.0,
                           usingSpringWithDamping: 0.7, initialSpringVelocity: 0.4) {
                nodeView.alpha = 1
                nodeView.transform = .identity
            }
        }
    }
}
