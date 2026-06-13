//
//  FocusSession.swift
//  FocusToolkit
//
//  CoreData record of a single focus (Pomodoro) session.
//

import Foundation
import CoreData

@objc(FocusSession)
final class FocusSession: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var duration: Int64
    @NSManaged var startDate: Date
    @NSManaged var endDate: Date?
    @NSManaged var isCompleted: Bool

    /// Insert a new session into the given context.
    @discardableResult
    static func create(in context: NSManagedObjectContext, duration: Int, startDate: Date = Date()) -> FocusSession {
        let s = FocusSession(context: context)
        s.id = UUID()
        s.duration = Int64(duration)
        s.startDate = startDate
        s.endDate = nil
        s.isCompleted = false
        return s
    }

    /// Fetch request for all completed sessions.
    static func completedRequest() -> NSFetchRequest<FocusSession> {
        let request = NSFetchRequest<FocusSession>(entityName: "FocusSession")
        request.predicate = NSPredicate(format: "isCompleted == YES")
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: true)]
        return request
    }

    /// Focused minutes actually elapsed (rounded), used by Stats.
    var focusedMinutes: Int {
        let seconds: Int
        if let endDate {
            seconds = max(0, Int(endDate.timeIntervalSince(startDate)))
        } else {
            seconds = Int(duration)
        }
        return Int((Double(seconds) / 60.0).rounded())
    }
}
