//
//  SettingsView.swift
//  FocusToolkit
//
//  Timer durations, notification preferences, and Focus Mode toggle.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState

    private let focusOptions = [15, 20, 25, 30, 45, 50, 60]
    private let breakOptions = [3, 5, 10, 15]

    var body: some View {
        NavigationView {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        timerCard
                        focusModeCard
                        notificationsCard
                        aboutCard
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Settings")
        }
        .navigationViewStyle(.stack)
    }

    // MARK: Timer durations

    private var timerCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 16) {
                label("Focus length", icon: "timer")
                chips(options: focusOptions, selected: appState.focusMinutes, suffix: "m") {
                    appState.focusMinutes = $0
                }

                Divider().overlay(Theme.cardStroke)

                label("Break length", icon: "cup.and.saucer.fill")
                chips(options: breakOptions, selected: appState.breakMinutes, suffix: "m") {
                    appState.breakMinutes = $0
                }
            }
        }
    }

    private func chips(options: [Int], selected: Int, suffix: String, onSelect: @escaping (Int) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(options, id: \.self) { value in
                    Button {
                        onSelect(value)
                        Haptics.tap()
                    } label: {
                        Text("\(value)\(suffix)")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(selected == value ? .black : Theme.textSecondary)
                            .frame(width: 56, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(selected == value ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.card))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: Focus Mode

    private var focusModeCard: some View {
        Card {
            Toggle(isOn: Binding(
                get: { appState.focusModeEnabled },
                set: { appState.focusModeEnabled = $0; Haptics.tap() }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    label("Focus Mode", icon: "moon.stars.fill")
                    Text("Hide everything except the timer and your current task.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .tint(Theme.accent)
        }
    }

    // MARK: Notifications

    private var notificationsCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: Binding(
                    get: { appState.notificationsEnabled },
                    set: { newValue in
                        appState.notificationsEnabled = newValue
                        if newValue {
                            Task { _ = await NotificationService.shared.requestAuthorization() }
                        }
                        Haptics.tap()
                    }
                )) {
                    label("Session alerts", icon: "bell.fill")
                }
                .tint(Theme.accent)

                Divider().overlay(Theme.cardStroke)

                Toggle(isOn: Binding(
                    get: { appState.dailyReminderEnabled },
                    set: { newValue in
                        appState.dailyReminderEnabled = newValue
                        Task {
                            if newValue {
                                let granted = await NotificationService.shared.requestAuthorization()
                                if granted { NotificationService.shared.scheduleDailyReminder(hour: 9, minute: 0) }
                            } else {
                                NotificationService.shared.cancelDailyReminder()
                            }
                        }
                        Haptics.tap()
                    }
                )) {
                    VStack(alignment: .leading, spacing: 4) {
                        label("Daily reminder", icon: "sun.max.fill")
                        Text("A gentle nudge at 9:00 AM.")
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .tint(Theme.accent)
            }
        }
    }

    // MARK: About

    private var aboutCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 8) {
                label("Focus Toolkit", icon: "sparkles")
                Text("Stay focused. Build better daily habits.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textSecondary)
                Text("Version 1.0")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func label(_ text: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.accent)
            Text(text)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.textPrimary)
        }
    }
}
