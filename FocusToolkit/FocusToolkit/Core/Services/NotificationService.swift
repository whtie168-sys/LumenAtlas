//
//  NotificationService.swift
//  FocusToolkit
//
//  Local notifications only (no backend): session end, break reminder,
//  and an optional daily reminder.
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    private let center = UNUserNotificationCenter.current()

    /// Request authorization. Safe to call repeatedly.
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    // MARK: Session-bound notifications

    /// Schedule a one-shot "focus session complete" notification after `seconds`.
    func scheduleSessionEnd(after seconds: TimeInterval) {
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Focus session complete"
        content.body = "Nice work. Time for a short break."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: Identifiers.sessionEnd, content: content, trigger: trigger)
        center.add(request)
    }

    /// Schedule a "break over" reminder after `seconds`.
    func scheduleBreakEnd(after seconds: TimeInterval) {
        guard seconds > 0 else { return }
        let content = UNMutableNotificationContent()
        content.title = "Break's over"
        content.body = "Ready to focus again?"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: Identifiers.breakEnd, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelSessionNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.sessionEnd, Identifiers.breakEnd])
    }

    // MARK: Daily reminder

    /// Schedule a repeating daily reminder at the given hour/minute.
    func scheduleDailyReminder(hour: Int = 9, minute: Int = 0) {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Stay consistent"
        content.body = "Take a moment to focus today."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: Identifiers.dailyReminder, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [Identifiers.dailyReminder])
    }

    private enum Identifiers {
        static let sessionEnd = "focus.session.end"
        static let breakEnd = "focus.break.end"
        static let dailyReminder = "focus.daily.reminder"
    }
}
