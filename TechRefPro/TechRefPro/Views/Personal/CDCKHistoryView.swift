//
//  CDCKHistoryView.swift
//  TechRefPro
//
//  Calculation history log with single-row delete and clear-all.
//

import SwiftUI

struct CDCKHistoryView: View {
    @EnvironmentObject var store: CDCKDataStore
    @State private var showClearConfirm = false

    var body: some View {
        NavigationView {
            Group {
                if store.history.isEmpty {
                    ScrollView {
                        CDCKEmptyState(systemImage: "clock.arrow.circlepath",
                                       title: "No history",
                                       message: "Calculations you run will be recorded here.")
                            .padding(.top, 60)
                    }
                } else {
                    List {
                        ForEach(store.history) { entry in
                            CDCKHistoryRow(entry: entry)
                                .listRowBackground(Color.clear)
                                .modifier(CDCKHiddenRowSeparator())
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                        .onDelete { store.deleteHistory(at: $0) }
                    }
                    .listStyle(.plain)
                    .modifier(CDCKHiddenScrollBackground())
                }
            }
            .cdckScreenBackground()
            .navigationBarTitle("History", displayMode: .large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !store.history.isEmpty {
                        Button {
                            showClearConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(CDCKTheme.amber)
                        }
                    }
                }
            }
            .actionSheet(isPresented: $showClearConfirm) {
                ActionSheet(title: Text("Clear all history?"),
                            message: Text("This cannot be undone."),
                            buttons: [
                                .destructive(Text("Clear All")) {
                                    store.clearHistory()
                                    CDCKHapticHelper.warning()
                                },
                                .cancel()
                            ])
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct CDCKHistoryRow: View {
    let entry: CDCKCalculationHistory

    private var inputSummary: String {
        entry.inputs
            .sorted { $0.key < $1.key }
            .map { "\($0.key) = \(CDCKFormatHelper.smart($0.value))" }
            .joined(separator: "  ")
    }

    var body: some View {
        CDCKCardView {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(entry.formulaName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(CDCKTheme.textPrimary)
                    Spacer()
                    Text("\(CDCKFormatHelper.smart(entry.result)) \(entry.resultUnit)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(CDCKTheme.accent)
                }
                if !inputSummary.isEmpty {
                    Text(inputSummary)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(CDCKTheme.textTertiary)
                }
                Text(CDCKFormatHelper.dateTime(entry.timestamp))
                    .font(.system(size: 11))
                    .foregroundColor(CDCKTheme.textTertiary)
            }
        }
    }
}

/// Hides the default List background on iOS 16+, no-op on iOS 14/15.
struct CDCKHiddenScrollBackground: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

/// Hides the row separator on iOS 15+, no-op on iOS 14.
struct CDCKHiddenRowSeparator: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content.listRowSeparator(.hidden)
        } else {
            content
        }
    }
}
