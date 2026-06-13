//
//  RootView.swift
//  FocusToolkit
//
//  Root navigation. In normal mode a TabView hosts all five tabs; in Focus
//  Mode the chrome collapses to just the timer (per spec).
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.focusModeEnabled {
                focusModeLayout
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                tabLayout
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.focusModeEnabled)
    }

    // MARK: Normal tabbed layout

    private var tabLayout: some View {
        TabView(selection: $appState.selectedTab) {
            HomeDashboardView()
                .tag(AppTab.timer)
                .tabItem { Label(AppTab.timer.title, systemImage: AppTab.timer.icon) }

            TasksView()
                .tag(AppTab.tasks)
                .tabItem { Label(AppTab.tasks.title, systemImage: AppTab.tasks.icon) }

            NotesView()
                .tag(AppTab.notes)
                .tabItem { Label(AppTab.notes.title, systemImage: AppTab.notes.icon) }

            StatsView()
                .tag(AppTab.stats)
                .tabItem { Label(AppTab.stats.title, systemImage: AppTab.stats.icon) }

            SettingsView()
                .tag(AppTab.settings)
                .tabItem { Label(AppTab.settings.title, systemImage: AppTab.settings.icon) }
        }
    }

    // MARK: Focus Mode layout (timer only)

    private var focusModeLayout: some View {
        FocusTimerView()
    }
}


