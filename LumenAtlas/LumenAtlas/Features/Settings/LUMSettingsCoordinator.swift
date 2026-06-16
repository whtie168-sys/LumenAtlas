//
//  LUMSettingsCoordinator.swift
//  LumenAtlas
//

import UIKit

final class LUMSettingsCoordinator: LUMNavigableCoordinator {

    override func start() {
        let viewModel = LUMSettingsViewModel(container: container)
        let settings = LUMSettingsViewController(viewModel: viewModel)
        settings.onManageTags = { [weak self] in self?.showTags() }
        settings.onConfigurePIN = { [weak self] in self?.showPINSetup() }
        settings.onImportExport = { [weak self] in self?.showImportExport() }
        settings.onAbout = { [weak self] in self?.showAbout() }
        settings.onStatistics = { [weak self] in self?.showStatistics() }
        navigationController.setViewControllers([settings], animated: false)
    }

    private func showTags() {
        let viewModel = LUMTagsViewModel(eventService: container.events)
        let tags = LUMTagsViewController(viewModel: viewModel)
        navigationController.pushViewController(tags, animated: true)
    }

    private func showPINSetup() {
        let mode: LUMPinViewModel.Mode = container.security.isPINEnabled ? .disable : .setup
        let viewModel = LUMPinViewModel(security: container.security, mode: mode)
        let pin = LUMPinViewController(viewModel: viewModel)
        pin.onUnlocked = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        navigationController.pushViewController(pin, animated: true)
    }

    private func showImportExport() {
        let viewModel = LUMImportExportViewModel(container: container)
        let ie = LUMImportExportViewController(viewModel: viewModel)
        navigationController.pushViewController(ie, animated: true)
    }

    private func showStatistics() {
        let viewModel = LUMStatisticsViewModel(eventService: container.events,
                                               analytics: container.analytics)
        let stats = LUMStatisticsViewController(viewModel: viewModel)
        navigationController.pushViewController(stats, animated: true)
    }

    private func showAbout() {
        navigationController.pushViewController(LUMAboutViewController(), animated: true)
    }
}
