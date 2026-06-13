//
//  StatsView.swift
//  FocusToolkit
//
//  Focus analytics: weekly bar chart (custom SwiftUI, iOS 15 compatible),
//  today's focus time, streak, and total completed sessions.
//

import SwiftUI
import CoreData

struct StatsView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = StatsViewModel()

    var body: some View {
        CompatNav {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        summaryGrid
                        weeklyChartCard
                        consistencyCard
                        achievementsCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Stats")
            .onAppear { vm.reload(context: viewContext, journeyCompleted: appState.journey.daysRemaining == 0) }
        }
    }

    // MARK: All achievements

    private var achievementsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                Text("Achievements")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)

                ForEach(Array(vm.achievements.enumerated()), id: \.element.id) { index, achievement in
                    AchievementRow(achievement: achievement)
                    if index < vm.achievements.count - 1 {
                        Divider().overlay(Theme.cardStroke)
                    }
                }
            }
        }
    }

    // MARK: Summary tiles

    private var summaryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            metric(value: "\(vm.todayMinutes)m", label: "Today", icon: "clock.fill", color: Theme.accentBlue)
            metric(value: "\(vm.streak)", label: "Day streak", icon: "flame.fill", color: Theme.warning)
            metric(value: "\(vm.totalSessions)", label: "Sessions", icon: "checkmark.seal.fill", color: Theme.accent)
            metric(value: "\(vm.bestDayMinutes)m", label: "Best day", icon: "trophy.fill", color: Theme.accentAlt)
        }
    }

    private func metric(value: String, label: String, icon: String, color: Color) -> some View {
        Card {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(color.opacity(0.15)))
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                    Text(label)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }
                Spacer()
            }
        }
    }

    // MARK: Weekly chart

    private var weeklyChartCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("This week")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text("Focus minutes")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                }

                if vm.week.allSatisfy({ $0.minutes == 0 }) {
                    Text("No focus time yet this week. Start a session to see your progress here.")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 160, alignment: .center)
                        .multilineTextAlignment(.center)
                } else {
                    WeeklyBarChart(days: vm.week)
                        .frame(height: 200)
                }
            }
        }
    }

    // MARK: Consistency strip

    private var consistencyCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Text("Consistency")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                HStack(spacing: 8) {
                    ForEach(vm.week) { day in
                        VStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(day.sessions > 0 ? Theme.accent : Theme.card)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(Theme.cardStroke, lineWidth: 1)
                                )
                                .frame(height: 36)
                                .overlay(
                                    Text(day.sessions > 0 ? "\(day.sessions)" : "")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(.black)
                                )
                            Text(String(day.weekday.prefix(1)))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(Theme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Weekly bar chart (custom, iOS 15 compatible)

private struct WeeklyBarChart: View {
    let days: [DayStat]

    private var maxMinutes: Int {
        max(1, days.map(\.minutes).max() ?? 1)
    }

    var body: some View {
        GeometryReader { geo in
            // Reserve space for the value label (top) and weekday label (bottom).
            let labelSpace: CGFloat = 38
            let barAreaHeight = max(0, geo.size.height - labelSpace)

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(days) { day in
                    let ratio = CGFloat(day.minutes) / CGFloat(maxMinutes)
                    let barHeight = day.minutes == 0 ? 4 : max(6, ratio * barAreaHeight)

                    VStack(spacing: 6) {
                        Text(day.minutes > 0 ? "\(day.minutes)" : "")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                            .frame(height: 12)

                        Spacer(minLength: 0)

                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(day.minutes > 0 ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.card))
                            .frame(height: barHeight)

                        Text(day.weekday)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.textTertiary)
                            .frame(height: 14)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
