//
//  LUMCoordinator.swift
//  LumenAtlas
//
//  Coordinator protocol plus the base behaviour shared by all coordinators:
//  child management so navigation flows can be pushed and popped without leaking.
//

import UIKit

protocol LUMCoordinator: AnyObject {
    var childCoordinators: [LUMCoordinator] { get set }
    func start()
}

extension LUMCoordinator {
    func addChild(_ child: LUMCoordinator) {
        childCoordinators.append(child)
    }

    func removeChild(_ child: LUMCoordinator?) {
        guard let child = child else { return }
        childCoordinators.removeAll { $0 === child }
    }
}
