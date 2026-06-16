//
//  LUMTabBarController.swift
//  LumenAtlas
//
//  The main interface: five tabs, each owning its own navigation stack and
//  feature coordinator. Styled to match the neon-dark theme with a translucent
//  blurred bar.
//

import UIKit

final class LUMTabBarController: UITabBarController {

    private let container: LUMServiceContainer
    private var featureCoordinators: [LUMCoordinator] = []

    init(container: LUMServiceContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        styleTabBar()
        installTabs()
    }

    private func installTabs() {
        let home = makeTab(coordinator: LUMHomeCoordinator(container: container),
                           title: "Home", systemImage: "square.grid.2x2.fill")
        let timeline = makeTab(coordinator: LUMTimelineCoordinator(container: container),
                               title: "Timeline", systemImage: "clock.fill")
        let analytics = makeTab(coordinator: LUMAnalyticsCoordinator(container: container),
                                title: "Analytics", systemImage: "waveform.path.ecg")
        let graph = makeTab(coordinator: LUMGraphCoordinator(container: container),
                            title: "Graph", systemImage: "network")
        let settings = makeTab(coordinator: LUMSettingsCoordinator(container: container),
                               title: "Settings", systemImage: "gearshape.fill")

        viewControllers = [home, timeline, analytics, graph, settings]
    }

    /// Spins up a feature coordinator, retains it, and returns its root nav
    /// controller configured with a tab item.
    private func makeTab(coordinator: LUMNavigableCoordinator,
                         title: String,
                         systemImage: String) -> UINavigationController {
        coordinator.start()
        featureCoordinators.append(coordinator)
        let nav = coordinator.navigationController
        nav.tabBarItem = UITabBarItem(title: title,
                                      image: UIImage(systemName: systemImage),
                                      selectedImage: nil)
        styleNavigationBar(nav)
        return nav
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = LUMPalette.surface.withAlphaComponent(0.85)
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterialDark)

        let normal = appearance.stackedLayoutAppearance.normal
        normal.iconColor = LUMPalette.textMuted
        normal.titleTextAttributes = [.foregroundColor: LUMPalette.textMuted,
                                      .font: LUMFont.caption(10)]
        let selected = appearance.stackedLayoutAppearance.selected
        selected.iconColor = LUMPalette.neonBlue
        selected.titleTextAttributes = [.foregroundColor: LUMPalette.neonBlue,
                                        .font: LUMFont.caption(10)]

        tabBar.standardAppearance = appearance
        // scrollEdgeAppearance on UITabBar is iOS 15+; the standard appearance
        // covers iOS 14 (where the bar isn't transparent at the scroll edge).
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        tabBar.tintColor = LUMPalette.neonBlue
    }

    private func styleNavigationBar(_ nav: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = LUMPalette.background.withAlphaComponent(0.6)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.titleTextAttributes = [.foregroundColor: LUMPalette.textPrimary,
                                          .font: LUMFont.heading(18)]
        appearance.largeTitleTextAttributes = [.foregroundColor: LUMPalette.textPrimary,
                                               .font: LUMFont.title(30)]
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = LUMPalette.neonBlue
        nav.navigationBar.prefersLargeTitles = true
    }
}
