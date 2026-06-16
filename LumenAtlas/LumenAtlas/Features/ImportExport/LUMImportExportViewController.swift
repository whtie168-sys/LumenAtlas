//
//  LUMImportExportViewController.swift
//  LumenAtlas
//
//  Local data management: export a JSON backup or text report via the share
//  sheet, restore from a picked file, or load sample data. All on-device.
//

import UIKit
import UniformTypeIdentifiers

final class LUMImportExportViewController: LUMBaseViewController {

    private let viewModel: LUMImportExportViewModel

    init(viewModel: LUMImportExportViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Import / Export"
        let (_, content) = makeScrollContainer()

        content.addArrangedSubview(makeInfoCard())

        let exportJSON = LUMNeonButton(title: "Export Backup (JSON)")
        exportJSON.addTarget(self, action: #selector(exportJSONTapped), for: .touchUpInside)
        content.addArrangedSubview(exportJSON)

        let exportReport = LUMNeonButton(title: "Export Report (Text)", style: .outline)
        exportReport.addTarget(self, action: #selector(exportReportTapped), for: .touchUpInside)
        content.addArrangedSubview(exportReport)

        let restore = LUMNeonButton(title: "Restore from Backup", style: .outline)
        restore.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        content.addArrangedSubview(restore)

        let sample = LUMNeonButton(title: "Load Sample Data", style: .outline)
        sample.addTarget(self, action: #selector(sampleTapped), for: .touchUpInside)
        content.addArrangedSubview(sample)
    }

    private func makeInfoCard() -> UIView {
        let card = LUMGlassCardView()
        let label = UILabel()
        label.numberOfLines = 0
        label.font = LUMFont.body(14)
        label.textColor = LUMPalette.textSecondary
        label.text = "All data lives only on this device. Export a backup to keep a copy, or restore one you saved earlier. Currently \(viewModel.eventCount) signals stored."
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

    // MARK: Actions

    @objc private func exportJSONTapped() {
        guard let url = viewModel.makeBackupFile() else {
            presentToast("Nothing to export yet.")
            return
        }
        share(url)
    }

    @objc private func exportReportTapped() {
        guard let url = viewModel.makeReportFile() else {
            presentToast("Nothing to export yet.")
            return
        }
        share(url)
    }

    @objc private func restoreTapped() {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    @objc private func sampleTapped() {
        let alert = UIAlertController(
            title: "Load sample data?",
            message: "This replaces your current signals with a generated sample set.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Load", style: .destructive) { [weak self] _ in
            self?.viewModel.loadSampleData()
            self?.presentToast("Sample data loaded.")
        })
        present(alert, animated: true)
    }

    private func share(_ url: URL) {
        let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        share.popoverPresentationController?.sourceView = view
        share.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.midX,
                                                                 y: view.bounds.midY,
                                                                 width: 0, height: 0)
        present(share, animated: true)
    }

    private func presentToast(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { alert.dismiss(animated: true) }
    }
}

extension LUMImportExportViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController,
                        didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        switch viewModel.restore(from: url) {
        case .success(let count):
            presentToast("Restored \(count) signals.")
        case .failure:
            presentToast("Could not read that backup file.")
        }
    }
}
