//
//  HomeViewModel.swift
//  FocusToolkit
//
//  Loads dashboard data (stats + achievements) for the Home screen.
//

import Foundation
import CoreData
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var stats: FocusStats = .empty
    @Published private(set) var recentAchievements: [Achievement] = []

    func reload(context: NSManagedObjectContext, journey: Journey) {
        let stats = FocusStats.load(context: context)
        self.stats = stats
        let journeyCompleted = journey.daysRemaining == 0
        recentAchievements = AchievementCatalog.recent(stats: stats, journeyCompleted: journeyCompleted)
    }
}
