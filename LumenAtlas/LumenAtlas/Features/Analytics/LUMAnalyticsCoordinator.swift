//
//  LUMAnalyticsCoordinator.swift
//  LumenAtlas
//

import UIKit

final class LUMAnalyticsCoordinator: LUMNavigableCoordinator {

    override func start() {
        let viewModel = LUMAnalyticsViewModel(eventService: container.events,
                                              analytics: container.analytics)
        let analytics = LUMAnalyticsViewController(viewModel: viewModel)
        analytics.onOpenInsights = { [weak self] in self?.showInsights() }
        navigationController.setViewControllers([analytics], animated: false)
    }

    private func showInsights() {
        let viewModel = LUMInsightViewModel(eventService: container.events,
                                            analytics: container.analytics,
                                            graphService: container.graph)
        let insights = LUMInsightViewController(viewModel: viewModel)
        navigationController.pushViewController(insights, animated: true)
    }
}
