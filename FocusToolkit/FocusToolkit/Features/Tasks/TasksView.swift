//
//  TasksView.swift
//  FocusToolkit
//
//  Daily task list: add, complete (tap), swipe to delete, set a task as the
//  current focus, and choose a repeat cadence.
//

import SwiftUI
import CoreData

struct TasksView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var vm = TasksViewModel()

    @FetchRequest(fetchRequest: TaskItem.allRequest()) private var tasks: FetchedResults<TaskItem>

    @State private var showingAdd = false

    private var openTasks: [TaskItem] { tasks.filter { !$0.isCompleted } }
    private var doneTasks: [TaskItem] { tasks.filter { $0.isCompleted } }

    var body: some View {
        CompatNav {
            ZStack {
                Theme.backgroundGradient.ignoresSafeArea()

                if tasks.isEmpty {
                    EmptyStateView(
                        icon: "checkmark.circle",
                        title: "No tasks yet",
                        message: "Add a few things you want to focus on today."
                    )
                } else {
                    List {
                        if !openTasks.isEmpty {
                            Section {
                                ForEach(openTasks) { task in
                                    taskRow(task)
                                }
                            } header: {
                                sectionHeader("To do", count: openTasks.count)
                            }
                        }

                        if !doneTasks.isEmpty {
                            Section {
                                ForEach(doneTasks) { task in
                                    taskRow(task)
                                }
                            } header: {
                                sectionHeader("Completed", count: doneTasks.count)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .compatHideScrollBackground()
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAdd = true
                        Haptics.tap()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddTaskSheet { title, repeatType in
                    vm.add(title: title, repeatType: repeatType)
                }
                .compatDetentHeight(320)
            }
            .onAppear { vm.configure(context: viewContext) }
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        Text("\(title) · \(count)")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Theme.textSecondary)
            .textCase(nil)
    }

    private func taskRow(_ task: TaskItem) -> some View {
        HStack(spacing: 12) {
            Button {
                vm.toggle(task)
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(task.isCompleted ? Theme.accent : Theme.textTertiary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .strikethrough(task.isCompleted)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(task.isCompleted ? Theme.textTertiary : Theme.textPrimary)
                if task.repeatType != .none {
                    TagChip(text: task.repeatType.label, systemImage: task.repeatType.icon, color: Theme.accentBlue)
                }
            }

            Spacer()

            // Set as current focus task
            Button {
                appState.currentFocusTaskTitle = task.title
                appState.selectedTab = .timer
                Haptics.success()
            } label: {
                Image(systemName: "target")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                vm.delete(task)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Add Task Sheet

private struct AddTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var repeatType: RepeatType = .none
    @FocusState private var fieldFocused: Bool

    let onAdd: (String, RepeatType) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New task")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Theme.textPrimary)

            TextField("What do you want to focus on?", text: $title)
                .font(.system(size: 16))
                .foregroundStyle(Theme.textPrimary)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.card))
                .focused($fieldFocused)
                .submitLabel(.done)
                .onSubmit(commit)

            VStack(alignment: .leading, spacing: 8) {
                Text("Repeat")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.textSecondary)
                HStack(spacing: 10) {
                    ForEach(RepeatType.allCases) { type in
                        Button {
                            repeatType = type
                            Haptics.tap()
                        } label: {
                            TagChip(
                                text: type.label,
                                systemImage: type.icon,
                                color: Theme.accent,
                                filled: repeatType == type
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            PrimaryButton(title: "Add task", systemImage: "plus") { commit() }

            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.backgroundElevated.ignoresSafeArea())
        .onAppear { fieldFocused = true }
    }

    private func commit() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        onAdd(trimmed, repeatType)
        dismiss()
    }
}
