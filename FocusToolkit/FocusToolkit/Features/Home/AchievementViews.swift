//
//  AchievementViews.swift
//  FocusToolkit
//
//  Badge UI for achievements: a compact circular badge (Home "recent" row)
//  and a detailed row with a progress bar (Stats "all" list).
//

import SwiftUI

/// Compact circular badge for the Home recent-achievements row.
struct AchievementBadge: View {
    let achievement: Achievement

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked
                          ? achievement.kind.tint.opacity(0.18)
                          : Color.white.opacity(0.06))
                    .frame(width: 60, height: 60)

                if achievement.isUnlocked {
                    Circle()
                        .stroke(achievement.kind.tint.opacity(0.6), lineWidth: 1.5)
                        .frame(width: 60, height: 60)
                } else {
                    // Thin progress ring for locked badges.
                    Circle()
                        .trim(from: 0, to: max(0.0001, achievement.progress))
                        .stroke(achievement.kind.tint.opacity(0.7),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 60, height: 60)
                }

                Image(systemName: achievement.kind.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? achievement.kind.tint : Theme.textTertiary)
            }

            Text(achievement.kind.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(achievement.isUnlocked ? Theme.textSecondary : Theme.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 72)
        }
    }
}

/// Detailed achievement row with icon, description, and a progress bar.
struct AchievementRow: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(achievement.isUnlocked
                          ? achievement.kind.tint.opacity(0.18)
                          : Color.white.opacity(0.05))
                    .frame(width: 48, height: 48)
                Image(systemName: achievement.kind.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(achievement.isUnlocked ? achievement.kind.tint : Theme.textTertiary)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(achievement.kind.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Text(achievement.progressLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(achievement.isUnlocked ? achievement.kind.tint : Theme.textSecondary)
                }

                if achievement.isUnlocked {
                    Text(achievement.kind.detail)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    ProgressBar(
                        progress: achievement.progress,
                        height: 6,
                        tint: AnyShapeStyle(achievement.kind.tint)
                    )
                }
            }
        }
        .opacity(achievement.isUnlocked ? 1 : 0.85)
    }
}
