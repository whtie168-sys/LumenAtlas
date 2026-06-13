//
//  FocusToolkitApp.swift
//  FocusToolkit
//
//  SwiftUI entry point. Injects the CoreData context and root navigation.
//  Targets iOS 15+.
//

import SwiftUI

@main
struct FocusToolkitApp: App {
    private let persistence = PersistenceController.shared
    @StateObject private var appState = AppState()

    init() {
        // iOS 15 fallbacks: clear default UIKit backgrounds so our dark theme
        // shows through List and TextEditor (the SwiftUI modifiers for these
        // only exist on iOS 16+).
        UITableView.appearance().backgroundColor = .clear
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistence.viewContext)
                .environmentObject(appState)
                .preferredColorScheme(.dark) // Dark mode first per spec
                .tint(Theme.accent)
        }
    }
}
