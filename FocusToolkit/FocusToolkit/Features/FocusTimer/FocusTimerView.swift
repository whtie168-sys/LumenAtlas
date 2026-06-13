//
//  FocusTimerView.swift
//  FocusToolkit
//
//  Home screen. The Pomodoro ring, controls, today's stats, and the
//  current-focus task line. Doubles as the Focus Mode minimal layout.
//

import SwiftUI
import CoreData

struct FocusTimerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = TimerViewModel()

    /// When presented as a cover from the dashboard, this dismisses it.
    /// Nil when shown as a tab/Focus Mode root.
    var onClose: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Theme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 28) {
                header

                Spacer(minLength: 0)

                TimerRing(
                    progress: vm.progress,
                    phaseTitle: vm.phase.title,
                    timeString: vm.timeString,
                    isRunning: vm.isRunning
                )
                .frame(width: 280, height: 280)

                currentTaskLine

                Spacer(minLength: 0)

                controls

                if !appState.focusModeEnabled {
                    statsRow
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
        .onAppear {
            vm.configure(
                context: viewContext,
                focusMinutes: appState.focusMinutes,
                breakMinutes: appState.breakMinutes,
                notificationsEnabled: appState.notificationsEnabled
            )
        }
    }

    // MARK: Header

    private var header: some View {
        HStack {
            // Close button only when presented as a cover from the dashboard.
            if let onClose {
                Button {
                    Haptics.tap()
                    onClose()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Theme.textSecondary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(Theme.card))
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(appState.focusModeEnabled ? "Focus Mode" : "Stay focused")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Theme.textPrimary)
                Text(appState.focusModeEnabled ? "Distractions off" : "One session at a time")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.textSecondary)
            }
            Spacer()
            Button {
                appState.focusModeEnabled.toggle()
                Haptics.tap()
            } label: {
                Image(systemName: appState.focusModeEnabled ? "moon.stars.fill" : "moon.stars")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(appState.focusModeEnabled ? Theme.accent : Theme.textSecondary)
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Theme.card))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Current task

    @ViewBuilder
    private var currentTaskLine: some View {
        if !appState.currentFocusTaskTitle.isEmpty {
            HStack(spacing: 8) {
                Image(systemName: "target")
                    .foregroundStyle(Theme.accent)
                Text(appState.currentFocusTaskTitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                Button {
                    appState.currentFocusTaskTitle = ""
                    Haptics.tap()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(Theme.card))
        }
    }

    // MARK: Controls

    private var controls: some View {
        HStack(spacing: 14) {
            // Stop
            Button {
                vm.stop()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.danger)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Theme.card))
            }
            .buttonStyle(.plain)

            // Start / Pause (primary)
            Button {
                vm.startPause()
            } label: {
                Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 84, height: 84)
                    .background(Circle().fill(Theme.accentGradient))
                    .shadow(color: Theme.accent.opacity(0.5), radius: 16, y: 6)
            }
            .buttonStyle(.plain)

            // Skip
            Button {
                vm.skipPhase()
            } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Theme.textSecondary)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Theme.card))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Stats row

    private var statsRow: some View {
        HStack(spacing: 12) {
            statTile(value: "\(vm.completedToday)", label: "Today", icon: "checkmark.seal.fill")
            statTile(value: "\(vm.streak)", label: "Streak", icon: "flame.fill")
            statTile(value: "\(appState.focusMinutes)m", label: "Length", icon: "timer")
        }
    }

    private func statTile(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Theme.card)
        )
    }
}
