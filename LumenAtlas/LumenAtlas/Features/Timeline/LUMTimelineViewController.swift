//
//  LUMTimelineViewController.swift
//  LumenAtlas
//
//  A sectioned table of events grouped by day, using the custom glass timeline
//  cell. Supports swipe-to-delete and routes taps to detail.
//

import UIKit

final class LUMTimelineViewController: LUMBaseViewController {

    var onSelectEvent: ((LUMEvent) -> Void)?
    var onAddEvent: (() -> Void)?
    var onOpenSearch: (() -> Void)?

    private let viewModel: LUMTimelineViewModel
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let emptyLabel = UILabel()

    init(viewModel: LUMTimelineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Timeline"
        configureNavBar()
        configureTable()
        configureEmptyState()
        viewModel.onChange = { [weak self] in self?.reload() }
        reload()
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill"),
                            style: .plain, target: self, action: #selector(addTapped)),
            UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                            style: .plain, target: self, action: #selector(searchTapped))
        ]
    }

    private func configureTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LUMTimelineCell.self, forCellReuseIdentifier: LUMTimelineCell.reuseID)
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureEmptyState() {
        emptyLabel.text = "No signals yet.\nTap + to capture your first moment."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = LUMFont.body(15)
        emptyLabel.textColor = LUMPalette.textSecondary
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }

    private func reload() {
        emptyLabel.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
        tableView.reloadData()
    }

    @objc private func addTapped() { onAddEvent?() }
    @objc private func searchTapped() { onOpenSearch?() }
}

// MARK: - Table data

extension LUMTimelineViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LUMTimelineCell.reuseID,
                                                 for: indexPath) as! LUMTimelineCell
        let event = viewModel.event(at: indexPath)
        let state = LUMTimelineCellState(
            title: event.title,
            timeText: LUMTimelineViewModel.timeFormatter.string(from: event.timestamp),
            composite: event.compositeScore,
            axisValues: LUMSignalAxis.allCases.map { ($0, event.value(for: $0)) },
            tags: event.tags)
        cell.configure(with: state)
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = viewModel.sections[section].title
        label.font = LUMFont.heading(15)
        label.textColor = LUMPalette.textSecondary
        let container = UIView()
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: LUMMetrics.screenInset),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 8)
        ])
        return container
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectEvent?(viewModel.event(at: indexPath))
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.viewModel.delete(at: indexPath)
            done(true)
        }
        delete.backgroundColor = LUMPalette.color(for: .stress)
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
