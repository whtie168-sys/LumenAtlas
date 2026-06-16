//
//  LUMHomeViewController.swift
//  LumenAtlas
//
//  The dashboard. Headline composite dial, four axis cards, a 7-day emotion
//  sparkline, recent anomalies and a recent-events list. Composes the custom
//  components into a scrollable glass layout.
//

import UIKit

final class LUMHomeViewController: LUMBaseViewController {

    var onAddEvent: (() -> Void)?
    var onSelectEvent: ((LUMEvent) -> Void)?

    private let viewModel: LUMHomeViewModel

    private let greetingLabel = UILabel()
    private let streakLabel = UILabel()
    private let dial = LUMEnergyDial(caption: "Composite", tint: LUMPalette.neonPurple)
    private let axisRow = UIStackView()
    private let trendChart = LUMLineChartView()
    private let anomaliesStack = UIStackView()
    private let recentStack = UIStackView()
    private var content: UIStackView!

    init(viewModel: LUMHomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Atlas"
        configureNavBar()
        buildLayout()
        viewModel.onChange = { [weak self] in self?.render() }
        render()
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem?.tintColor = LUMPalette.neonBlue
    }

    private func buildLayout() {
        let (_, content) = makeScrollContainer()
        self.content = content

        // Greeting header.
        greetingLabel.font = LUMFont.title(26)
        greetingLabel.textColor = LUMPalette.textPrimary
        streakLabel.font = LUMFont.caption(13)
        streakLabel.textColor = LUMPalette.neonCyan
        let header = UIStackView(arrangedSubviews: [greetingLabel, streakLabel])
        header.axis = .vertical
        header.spacing = 2
        content.addArrangedSubview(header)

        // Headline dial card.
        let dialCard = LUMGlassCardView()
        dial.translatesAutoresizingMaskIntoConstraints = false
        dialCard.contentView.addSubview(dial)
        NSLayoutConstraint.activate([
            dial.topAnchor.constraint(equalTo: dialCard.contentView.topAnchor, constant: 8),
            dial.bottomAnchor.constraint(equalTo: dialCard.contentView.bottomAnchor, constant: -8),
            dial.centerXAnchor.constraint(equalTo: dialCard.contentView.centerXAnchor),
            dial.widthAnchor.constraint(equalToConstant: 150),
            dial.heightAnchor.constraint(equalToConstant: 150)
        ])
        content.addArrangedSubview(dialCard)

        // Axis summary row (4 mini cards).
        axisRow.axis = .horizontal
        axisRow.distribution = .fillEqually
        axisRow.spacing = 10
        content.addArrangedSubview(axisRow)

        // Emotion trend card.
        content.addArrangedSubview(makeSectionTitle("7-Day Emotion Trend"))
        let chartCard = LUMGlassCardView()
        trendChart.translatesAutoresizingMaskIntoConstraints = false
        chartCard.contentView.addSubview(trendChart)
        NSLayoutConstraint.activate([
            trendChart.topAnchor.constraint(equalTo: chartCard.contentView.topAnchor),
            trendChart.bottomAnchor.constraint(equalTo: chartCard.contentView.bottomAnchor),
            trendChart.leadingAnchor.constraint(equalTo: chartCard.contentView.leadingAnchor),
            trendChart.trailingAnchor.constraint(equalTo: chartCard.contentView.trailingAnchor),
            trendChart.heightAnchor.constraint(equalToConstant: 140)
        ])
        content.addArrangedSubview(chartCard)

        // Anomalies.
        content.addArrangedSubview(makeSectionTitle("Signals to Notice"))
        anomaliesStack.axis = .vertical
        anomaliesStack.spacing = 8
        content.addArrangedSubview(anomaliesStack)

        // Recent events.
        content.addArrangedSubview(makeSectionTitle("Recent"))
        recentStack.axis = .vertical
        recentStack.spacing = 8
        content.addArrangedSubview(recentStack)
    }

    // MARK: Rendering

    private func render() {
        greetingLabel.text = viewModel.greeting
        streakLabel.text = viewModel.streakDays > 0
            ? "🔥 \(viewModel.streakDays)-day logging streak"
            : "Start your first signal log"

        dial.setValue(viewModel.composite, animated: true)

        // Axis mini-cards.
        axisRow.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for summary in viewModel.axisSummaries {
            axisRow.addArrangedSubview(makeAxisCard(summary))
        }

        trendChart.update(points: viewModel.emotionTrend.points, tint: LUMPalette.neonPink)

        // Anomalies.
        anomaliesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if viewModel.anomalies.isEmpty {
            anomaliesStack.addArrangedSubview(makeEmptyRow("No unusual readings — steady signals."))
        } else {
            for anomaly in viewModel.anomalies {
                anomaliesStack.addArrangedSubview(makeAnomalyRow(anomaly))
            }
        }

        // Recent events.
        recentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if viewModel.recentEvents.isEmpty {
            recentStack.addArrangedSubview(makeEmptyRow("Tap + to capture your first moment."))
        } else {
            for event in viewModel.recentEvents {
                recentStack.addArrangedSubview(makeRecentRow(event))
            }
        }
    }

    // MARK: Builders

    private func makeSectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = LUMFont.heading(18)
        label.textColor = LUMPalette.textPrimary
        return label
    }

    private func makeAxisCard(_ summary: LUMHomeViewModel.AxisSummary) -> UIView {
        let card = LUMGlassCardView()
        let color = LUMPalette.color(for: summary.axis)

        let glyph = UILabel()
        glyph.text = summary.axis.glyph
        glyph.font = LUMFont.body(16)
        glyph.textColor = color

        let value = UILabel()
        value.text = "\(summary.current)"
        value.font = LUMFont.mono(22)
        value.textColor = LUMPalette.textPrimary

        let arrow = UILabel()
        arrow.font = LUMFont.caption(11)
        switch summary.trend {
        case .rising:  arrow.text = "▲"; arrow.textColor = LUMPalette.neonCyan
        case .falling: arrow.text = "▼"; arrow.textColor = LUMPalette.neonPink
        case .flat:    arrow.text = "▬"; arrow.textColor = LUMPalette.textMuted
        }

        let stack = UIStackView(arrangedSubviews: [glyph, value, arrow])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
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

    private func makeAnomalyRow(_ anomaly: LUMAnomaly) -> UIView {
        let card = LUMGlassCardView()
        let icon = UILabel()
        icon.text = anomaly.kind == .spike ? "⚠︎" : "✦"
        icon.textColor = anomaly.kind == .spike ? LUMPalette.color(for: .stress) : LUMPalette.neonCyan
        icon.font = LUMFont.heading(18)

        let text = UILabel()
        text.numberOfLines = 2
        let kindWord = anomaly.kind == .spike ? "spike" : "peak"
        text.attributedText = decorated(
            "\(anomaly.axis.title) \(kindWord) — \(anomaly.value)",
            detail: String(format: " (%.1fσ)", anomaly.deviation))

        let stack = UIStackView(arrangedSubviews: [icon, text])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        embed(stack, in: card)
        return card
    }

    private func makeRecentRow(_ event: LUMEvent) -> UIView {
        let card = LUMGlassCardView()
        let title = UILabel()
        title.text = event.title
        title.font = LUMFont.body(15)
        title.textColor = LUMPalette.textPrimary

        let dot = UIView()
        dot.backgroundColor = LUMPalette.moodColor(Double(event.compositeScore))
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let time = UILabel()
        time.text = Self.relativeFormatter.localizedString(for: event.timestamp, relativeTo: Date())
        time.font = LUMFont.caption(12)
        time.textColor = LUMPalette.textSecondary

        let stack = UIStackView(arrangedSubviews: [dot, title, UIView(), time])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        embed(stack, in: card)

        card.isUserInteractionEnabled = true
        let tap = LUMTapAction { [weak self] in self?.onSelectEvent?(event) }
        card.addAction(tap)
        return card
    }

    private func makeEmptyRow(_ text: String) -> UIView {
        let card = LUMGlassCardView()
        let label = UILabel()
        label.text = text
        label.font = LUMFont.body(14)
        label.textColor = LUMPalette.textSecondary
        label.numberOfLines = 0
        embed(label, in: card)
        return card
    }

    private func embed(_ view: UIView, in card: LUMGlassCardView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        card.contentView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: card.contentView.topAnchor),
            view.bottomAnchor.constraint(equalTo: card.contentView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: card.contentView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: card.contentView.trailingAnchor)
        ])
    }

    private func decorated(_ main: String, detail: String) -> NSAttributedString {
        let result = NSMutableAttributedString(
            string: main,
            attributes: [.foregroundColor: LUMPalette.textPrimary, .font: LUMFont.body(14)])
        result.append(NSAttributedString(
            string: detail,
            attributes: [.foregroundColor: LUMPalette.textMuted, .font: LUMFont.caption(12)]))
        return result
    }

    @objc private func addTapped() { onAddEvent?() }

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()
}
