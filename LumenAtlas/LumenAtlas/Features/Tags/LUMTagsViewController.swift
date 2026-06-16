//
//  LUMTagsViewController.swift
//  LumenAtlas
//
//  Tag management list. Each row shows the tag, its colour swatch and usage,
//  with pin/recolour/delete via swipe and tap.
//

import UIKit

final class LUMTagsViewController: LUMBaseViewController {

    private let viewModel: LUMTagsViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyLabel = UILabel()

    init(viewModel: LUMTagsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tags"
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 32, right: 0)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tag")
        view.addSubview(tableView)

        emptyLabel.text = "Tags appear here as you add them to signals."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.font = LUMFont.body(15)
        emptyLabel.textColor = LUMPalette.textSecondary
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])

        viewModel.onChange = { [weak self] in self?.reload() }
        reload()
    }

    private func reload() {
        emptyLabel.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
        tableView.reloadData()
    }
}

extension LUMTagsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tag", for: indexPath)
        let item = viewModel.items[indexPath.row]
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.contentConfiguration = nil

        // Build a compact custom content view.
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let swatch = UIView()
        swatch.backgroundColor = LUMPalette.tagColor(item.tag.colorIndex)
        swatch.layer.cornerRadius = 6
        swatch.translatesAutoresizingMaskIntoConstraints = false

        let name = UILabel()
        name.text = (item.tag.isPinned ? "📌 " : "") + "#\(item.tag.slug)"
        name.font = LUMFont.body(16)
        name.textColor = LUMPalette.textPrimary

        let usage = UILabel()
        usage.text = "\(item.usageCount)"
        usage.font = LUMFont.mono(14)
        usage.textColor = LUMPalette.textSecondary

        let stack = UIStackView(arrangedSubviews: [swatch, name, UIView(), usage])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            swatch.widthAnchor.constraint(equalToConstant: 14),
            swatch.heightAnchor.constraint(equalToConstant: 14),
            stack.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -12),
            stack.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: LUMMetrics.screenInset),
            stack.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -LUMMetrics.screenInset)
        ])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.cycleColor(viewModel.items[indexPath.row])
    }

    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let item = viewModel.items[indexPath.row]
        let pin = UIContextualAction(style: .normal,
                                     title: item.tag.isPinned ? "Unpin" : "Pin") { [weak self] _, _, done in
            self?.viewModel.togglePin(item)
            done(true)
        }
        pin.backgroundColor = LUMPalette.neonPurple
        return UISwipeActionsConfiguration(actions: [pin])
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.viewModel.delete(self!.viewModel.items[indexPath.row])
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
