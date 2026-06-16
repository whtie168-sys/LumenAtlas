//
//  LUMSearchViewController.swift
//  LumenAtlas
//
//  Search screen: a search bar, quick tag chips, an axis-threshold filter and a
//  live result list reusing the timeline cell.
//

import UIKit

final class LUMSearchViewController: LUMBaseViewController {

    var onSelectEvent: ((LUMEvent) -> Void)?

    private let viewModel: LUMSearchViewModel
    private let searchBar = UISearchBar()
    private let chipsScroll = UIScrollView()
    private let chipsStack = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let resultCountLabel = UILabel()

    init(viewModel: LUMSearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        buildLayout()
        viewModel.onChange = { [weak self] in self?.reload() }
        reload()
    }

    private func buildLayout() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search title, note or tag"
        searchBar.delegate = self
        searchBar.tintColor = LUMPalette.neonBlue
        searchBar.searchTextField.textColor = LUMPalette.textPrimary
        view.addSubview(searchBar)

        chipsScroll.translatesAutoresizingMaskIntoConstraints = false
        chipsScroll.showsHorizontalScrollIndicator = false
        chipsStack.axis = .horizontal
        chipsStack.spacing = 8
        chipsStack.translatesAutoresizingMaskIntoConstraints = false
        chipsScroll.addSubview(chipsStack)
        view.addSubview(chipsScroll)

        resultCountLabel.font = LUMFont.caption(12)
        resultCountLabel.textColor = LUMPalette.textSecondary
        resultCountLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(resultCountLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LUMTimelineCell.self, forCellReuseIdentifier: LUMTimelineCell.reuseID)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            chipsScroll.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            chipsScroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chipsScroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chipsScroll.heightAnchor.constraint(equalToConstant: 36),

            chipsStack.topAnchor.constraint(equalTo: chipsScroll.topAnchor),
            chipsStack.bottomAnchor.constraint(equalTo: chipsScroll.bottomAnchor),
            chipsStack.leadingAnchor.constraint(equalTo: chipsScroll.leadingAnchor, constant: LUMMetrics.screenInset),
            chipsStack.trailingAnchor.constraint(equalTo: chipsScroll.trailingAnchor, constant: -LUMMetrics.screenInset),
            chipsStack.heightAnchor.constraint(equalTo: chipsScroll.heightAnchor),

            resultCountLabel.topAnchor.constraint(equalTo: chipsScroll.bottomAnchor, constant: 6),
            resultCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: LUMMetrics.screenInset),

            tableView.topAnchor.constraint(equalTo: resultCountLabel.bottomAnchor, constant: 4),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        buildChips()
    }

    private func buildChips() {
        for tag in viewModel.suggestedTags {
            let chip = makeChip(tag)
            chipsStack.addArrangedSubview(chip)
        }
    }

    private func makeChip(_ tag: String) -> UIView {
        let button = UIButton(type: .system)
        button.setTitle(tag, for: .normal)
        button.titleLabel?.font = LUMFont.caption(13)
        button.setTitleColor(LUMPalette.neonBlue, for: .normal)
        button.backgroundColor = LUMPalette.neonBlue.withAlphaComponent(0.12)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        button.layer.cornerRadius = 14
        button.addAction(UIAction { [weak self] _ in
            self?.searchBar.text = tag
            self?.viewModel.query = tag
        }, for: .touchUpInside)
        return button
    }

    private func reload() {
        let count = viewModel.results.count
        resultCountLabel.text = "\(count) result\(count == 1 ? "" : "s")"
        tableView.reloadData()
    }
}

extension LUMSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.query = searchText
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension LUMSearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LUMTimelineCell.reuseID,
                                                 for: indexPath) as! LUMTimelineCell
        let event = viewModel.results[indexPath.row]
        cell.configure(with: LUMTimelineCellState(
            title: event.title,
            timeText: LUMTimelineViewModel.timeFormatter.string(from: event.timestamp),
            composite: event.compositeScore,
            axisValues: LUMSignalAxis.allCases.map { ($0, event.value(for: $0)) },
            tags: event.tags))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onSelectEvent?(viewModel.results[indexPath.row])
    }
}
