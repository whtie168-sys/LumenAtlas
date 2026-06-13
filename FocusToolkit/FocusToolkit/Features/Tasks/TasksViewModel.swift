//
//  TasksViewModel.swift
//  FocusToolkit
//
//  Task CRUD plus repeat handling (daily/weekly auto-reset of completion).
//

import Foundation
import CoreData
import Combine

@MainActor
final class TasksViewModel: ObservableObject {
    private var context: NSManagedObjectContext?

    func configure(context: NSManagedObjectContext) {
        self.context = context
        rolloverRepeatingTasks()
    }

    func add(title: String, repeatType: RepeatType) {
        guard let context else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        TaskItem.create(in: context, title: trimmed, repeatType: repeatType)
        save()
        Haptics.success()
    }

    func toggle(_ task: TaskItem) {
        task.isCompleted.toggle()
        save()
        Haptics.tap()
    }

    func delete(_ task: TaskItem) {
        context?.delete(task)
        save()
        Haptics.warning()
    }

    /// Reset completion for repeating tasks when a new day/week has begun.
    func rolloverRepeatingTasks() {
        guard let context else { return }
        let tasks = (try? context.fetch(TaskItem.allRequest())) ?? []
        let cal = DateUtils.calendar
        let now = Date()
        var changed = false

        for task in tasks where task.isCompleted {
            switch task.repeatType {
            case .none:
                break
            case .daily:
                if !DateUtils.isSameDay(task.lastResetDate, now) {
                    task.isCompleted = false
                    task.lastResetDate = now
                    changed = true
                }
            case .weekly:
                if !cal.isDate(task.lastResetDate, equalTo: now, toGranularity: .weekOfYear) {
                    task.isCompleted = false
                    task.lastResetDate = now
                    changed = true
                }
            }
        }
        if changed { save() }
    }

    private func save() {
        guard let context, context.hasChanges else { return }
        try? context.save()
    }
}
