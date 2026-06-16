//
//  LUMGraphCoordinator.swift
//  LumenAtlas
//

import UIKit

final class LUMGraphCoordinator: LUMNavigableCoordinator {

    override func start() {
        let viewModel = LUMGraphViewModel(eventService: container.events,
                                          graphService: container.graph)
        let graph = LUMGraphViewController(viewModel: viewModel)
        graph.onSelectTag = { [weak self] tag in
            self?.showTagDetail(tag)
        }
        navigationController.setViewControllers([graph], animated: false)
    }

    private func showTagDetail(_ tag: String) {
        let viewModel = LUMTagDetailViewModel(tag: tag,
                                              eventService: container.events,
                                              graphService: container.graph,
                                              analytics: container.analytics)
        let detail = LUMTagDetailViewController(viewModel: viewModel)
        detail.onSelectEvent = { [weak self] event in
            self?.showDetail(for: event)
        }
        navigationController.pushViewController(detail, animated: true)
    }
}
