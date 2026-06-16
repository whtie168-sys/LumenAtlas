//
//  LUMAnalyticsViewController.swift
//  LumenAtlas
//
//  Analytics tab: a window selector, four per-axis trend charts, the focus
//  distribution histogram, a ranked tag list and detected time clusters.
//

import UIKit

final class LUMAnalyticsViewController: LUMBaseViewController {

    var onOpenInsights: (() -> Void)?

    private let viewModel: LUMAnalyticsViewModel
    private let segmented = UISegmentedControl(items: LUMAnalyticsViewModel.Window.allCases.map(\.title))
    private var content: UIStackView!
    private var trendCharts: [LUMSignalAxis: LUMLineChartView] = [:]
    private let distributionChart = LUMBarChartView()
    private let tagChart = LUMBarChartView()
    private let clustersStack = UIStackView()

    init(viewModel: LUMAnalyticsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "lightbulb.fill"),
            style: .plain, target: self, action: #selector(insightsTapped))
        buildLayout()
        viewModel.onChange = { [weak self] in self?.render() }
        render()
    }

    private func buildLayout() {
        let (_, content) = makeScrollContainer()
        self.content = content

        segmented.selectedSegmentIndex = LUMAnalyticsViewModel.Window.allCases
            .firstIndex(of: viewModel.window) ?? 1
        segmented.selectedSegmentTintColor = LUMPalette.neonBlue
        segmented.setTitleTextAttributes([.foregroundColor: LUMPalette.textSecondary], for: .normal)
        segmented.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmented.addTarget(self, action: #selector(windowChanged), for: .valueChanged)
        content.addArrangedSubview(segmented)

        // Trend charts.
        content.addArrangedSubview(makeSectionTitle("Signal Trends (7-day rolling avg)"))
        for axis in LUMSignalAxis.allCases {
            let chart = LUMLineChartView()
            trendCharts[axis] = chart
            content.addArrangedSubview(makeChartCard(title: "\(axis.glyph)  \(axis.title)",
                                                     chart: chart, height: 120))
        }

        // Focus distribution.
        content.addArrangedSubview(makeSectionTitle("Focus Distribution"))
        content.addArrangedSubview(makeChartCard(title: nil, chart: distributionChart, height: 150))

        // Tag ranking.
        content.addArrangedSubview(makeSectionTitle("Top Tags"))
        content.addArrangedSubview(makeChartCard(title: nil, chart: tagChart, height: 150))

        // Clusters.
        content.addArrangedSubview(makeSectionTitle("Activity Episodes"))
        clustersStack.axis = .vertical
        clustersStack.spacing = 8
        content.addArrangedSubview(clustersStack)
    }

    // MARK: Render

    private func render() {
        for (axis, chart) in trendCharts {
            let series = viewModel.trends.first { $0.axis == axis }
            chart.update(points: series?.points ?? [], tint: LUMPalette.color(for: axis))
        }

        if let dist = viewModel.focusDistribution {
            distributionChart.update(bars: dist.buckets.map {
                LUMBarChartView.Bar(value: Double($0.count),
                                    label: $0.label,
                                    color: LUMPalette.color(for: .focus))
            })
        }

        tagChart.update(bars: viewModel.tagRanks.map {
            LUMBarChartView.Bar(value: Double($0.count),
                                label: $0.tag,
                                color: LUMPalette.moodColor($0.averageComposite))
        })

        clustersStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if viewModel.clusters.isEmpty {
            clustersStack.addArrangedSubview(makeEmptyRow("Not enough data to detect episodes yet."))
        } else {
            for cluster in viewModel.clusters {
                clustersStack.addArrangedSubview(makeClusterRow(cluster))
            }
        }
    }

    // MARK: Builders

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = LUMFont.heading(17)
        label.textColor = LUMPalette.textPrimary
        return label
    }

    private func makeChartCard(title: String?, chart: UIView, height: CGFloat) -> UIView {
        let card = LUMGlassCardView()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false

        if let title = title {
            let label = UILabel()
            label.text = title
            label.font = LUMFont.caption(13)
            label.textColor = LUMPalette.textSecondary
            stack.addArrangedSubview(label)
        }
        chart.translatesAutoresizingMaskIntoConstraints = false
        chart.heightAnchor.constraint(equalToConstant: height).isActive = true
        stack.addArrangedSubview(chart)

        card.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
        return card
    }

    private func makeClusterRow(_ cluster: LUMCluster) -> UIView {
        let card = LUMGlassCardView()
        let title = UILabel()
        title.font = LUMFont.body(15)
        title.textColor = LUMPalette.textPrimary
        title.text = "\(cluster.size) events over \(Self.durationText(cluster.span))"

        let badge = UILabel()
        badge.font = LUMFont.mono(15)
        badge.textColor = LUMPalette.moodColor(cluster.averageComposite)
        badge.text = "\(Int(cluster.averageComposite))"

        let stack = UIStackView(arrangedSubviews: [title, UIView(), badge])
        stack.axis = .horizontal
        stack.alignment = .center
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

    private func makeEmptyRow(_ text: String) -> UIView {
        let card = LUMGlassCardView()
        let label = UILabel()
        label.text = text
        label.font = LUMFont.body(14)
        label.textColor = LUMPalette.textSecondary
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            label.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
        return card
    }

    private static func durationText(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        if hours < 1 { return "under an hour" }
        if hours < 24 { return "\(hours)h" }
        return "\(hours / 24)d \(hours % 24)h"
    }

    // MARK: Actions

    @objc private func windowChanged() {
        let windows = LUMAnalyticsViewModel.Window.allCases
        viewModel.window = windows[segmented.selectedSegmentIndex]
    }

    @objc private func insightsTapped() { onOpenInsights?() }
}
