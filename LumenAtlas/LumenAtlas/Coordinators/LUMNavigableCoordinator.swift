//
//  LUMNavigableCoordinator.swift
//  LumenAtlas
//
//  A coordinator that owns a UINavigationController. Each tab is driven by one
//  of these; the tab bar starts it and installs its `navigationController`.
//

import UIKit

class LUMNavigableCoordinator: LUMCoordinator {

    var childCoordinators: [LUMCoordinator] = []
    let navigationController: UINavigationController
    let container: LUMServiceContainer

    init(container: LUMServiceContainer,
         navigationController: UINavigationController = UINavigationController()) {
        self.container = container
        self.navigationController = navigationController
    }

    /// Subclasses override to install their root view controller.
    func start() {
        fatalError("Subclasses must override start()")
    }

    /// Shared push into the Add Event flow, used by Home and Timeline.
    func presentAddEvent(prefillFrom existing: LUMEvent? = nil,
                         onComplete: @escaping () -> Void = {}) {
        let viewModel = LUMAddEventViewModel(eventService: container.events,
                                             editing: existing)
        let addVC = LUMAddEventViewController(viewModel: viewModel)
        addVC.onFinished = { [weak self] in
            self?.navigationController.dismiss(animated: true)
            onComplete()
        }
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true)
    }

    /// Shared push into an event's detail screen.
    func showDetail(for event: LUMEvent) {
        let viewModel = LUMDetailViewModel(event: event,
                                           eventService: container.events,
                                           analytics: container.analytics)
        let detail = LUMDetailViewController(viewModel: viewModel)
        detail.onEdit = { [weak self] toEdit in
            self?.presentAddEvent(prefillFrom: toEdit)
        }
        navigationController.pushViewController(detail, animated: true)
    }
}
