//
//  LUMHomeCoordinator.swift
//  LumenAtlas
//
//  Drives the dashboard tab: shows the home screen and routes the "add event",
//  "open detail" and "see all" intents it raises.
//

import UIKit

final class LUMHomeCoordinator: LUMNavigableCoordinator {

    override func start() {
        let viewModel = LUMHomeViewModel(eventService: container.events,
                                         analytics: container.analytics)
        let home = LUMHomeViewController(viewModel: viewModel)
        home.onAddEvent = { [weak self] in
            self?.presentAddEvent()
        }
        home.onSelectEvent = { [weak self] event in
            self?.showDetail(for: event)
        }
        navigationController.setViewControllers([home], animated: false)
    }
}
