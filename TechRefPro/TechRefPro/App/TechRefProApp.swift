//
//  TechRefProApp.swift
//  TechRefPro
//
//  SwiftUI application entry point. Owns the shared data store and forces
//  the dark appearance regardless of system setting.
//

import SwiftUI

@main
struct TechRefProApp: App {
    @StateObject private var store = CDCKDataStore()

    var body: some Scene {
        WindowGroup {
            CDCKRootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}
