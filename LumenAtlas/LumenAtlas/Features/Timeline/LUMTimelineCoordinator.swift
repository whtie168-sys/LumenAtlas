//
//  LUMTimelineCoordinator.swift
//  LumenAtlas
//

import UIKit

final class LUMTimelineCoordinator: LUMNavigableCoordinator {

    override func start() {
        let viewModel = LUMTimelineViewModel(eventService: container.events)
        let timeline = LUMTimelineViewController(viewModel: viewModel)
        timeline.onSelectEvent = { [weak self] event in
            self?.showDetail(for: event)
        }
        timeline.onAddEvent = { [weak self] in
            self?.presentAddEvent()
        }
        timeline.onOpenSearch = { [weak self] in
            self?.showSearch()
        }
        navigationController.setViewControllers([timeline], animated: false)
    }

    private func showSearch() {
        let viewModel = LUMSearchViewModel(eventService: container.events)
        let search = LUMSearchViewController(viewModel: viewModel)
        search.onSelectEvent = { [weak self] event in
            self?.showDetail(for: event)
        }
        navigationController.pushViewController(search, animated: true)
    }
}
