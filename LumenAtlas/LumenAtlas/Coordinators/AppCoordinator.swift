//
//  AppCoordinator.swift
//  LumenAtlas
//
//  Root coordinator. Owns the window, performs first-launch seeding, gates the
//  app behind the PIN lock when enabled, and installs the main tab interface.
//

import UIKit

final class AppCoordinator: LUMCoordinator {

    var childCoordinators: [LUMCoordinator] = []

    private let window: UIWindow
    private let container: LUMServiceContainer
    private var isLocked = false

    init(window: UIWindow, container: LUMServiceContainer = LUMServiceContainer()) {
        self.window = window
        self.container = container
    }

    func start() {
        container.seedIfNeeded()
        // Show the animated launch glow first; it hands off to the main UI.
        let launch = LUMLaunchViewController()
        launch.onFinished = { [weak self] in
            self?.presentGatedRoot()
        }
        window.rootViewController = launch
    }

    // MARK: Lock lifecycle

    func applicationDidEnterBackground() {
        guard container.security.isPINEnabled else { return }
        isLocked = true
    }

    func applicationWillEnterForeground() {
        guard isLocked, container.security.isPINEnabled else { return }
        presentLock()
    }

    // MARK: Private

    private func presentGatedRoot() {
        if container.security.isPINEnabled {
            presentLock()
        } else {
            installMainInterface()
        }
    }

    private func installMainInterface() {
        let tab = LUMTabBarController(container: container)
        transition(to: tab)
    }

    private func presentLock() {
        let viewModel = LUMPinViewModel(security: container.security, mode: .unlock)
        let lock = LUMPinViewController(viewModel: viewModel)
        lock.onUnlocked = { [weak self] in
            self?.isLocked = false
            self?.installMainInterface()
        }
        transition(to: lock)
    }

    /// Cross-fade between root controllers for a polished feel.
    private func transition(to viewController: UIViewController) {
        guard let current = window.rootViewController, current !== viewController else {
            window.rootViewController = viewController
            return
        }
        UIView.transition(with: window,
                          duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.window.rootViewController = viewController
        })
    }
}
