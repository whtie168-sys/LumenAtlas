//
//  SceneDelegate.swift
//  LumenAtlas
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = .dark

        let coordinator = AppCoordinator(window: window)
        coordinator.start()

        self.window = window
        self.appCoordinator = coordinator
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Re-arm the privacy lock so the next foreground requires the PIN.
        appCoordinator?.applicationDidEnterBackground()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        appCoordinator?.applicationWillEnterForeground()
    }
}
