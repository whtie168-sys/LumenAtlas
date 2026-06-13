//
//  TaskItem.swift
//  FocusToolkit
//
//  CoreData task with optional daily/weekly repeat.
//

import Foundation
import CoreData

enum RepeatType: String, CaseIterable, Identifiable {
    case none, daily, weekly
    var id: String { rawValue }

    var label: String {
        switch self {
        case .none: return "Once"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }

    var icon: String {
        switch self {
        case .none: return "1.circle"
        case .daily: return "repeat"
        case .weekly: return "calendar"
        }
    }
}

@objc(TaskItem)
final class TaskItem: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var isCompleted: Bool
    @NSManaged var createdAt: Date
    /// Stored raw value of `RepeatType`.
    @NSManaged var repeatRaw: String
    /// Last date this task was auto-rolled forward (for repeat handling).
    @NSManaged var lastResetDate: Date

    @discardableResult
    static func create(in context: NSManagedObjectContext, title: String, repeatType: RepeatType) -> TaskItem {
        let t = TaskItem(context: context)
        let now = Date()
        t.id = UUID()
        t.title = title
        t.isCompleted = false
        t.createdAt = now
        t.repeatRaw = repeatType.rawValue
        t.lastResetDate = now
        return t
    }

    /// All tasks, newest first.
    static func allRequest() -> NSFetchRequest<TaskItem> {
        let request = NSFetchRequest<TaskItem>(entityName: "TaskItem")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        return request
    }

    var repeatType: RepeatType {
        get { RepeatType(rawValue: repeatRaw) ?? .none }
        set { repeatRaw = newValue.rawValue }
    }
}
