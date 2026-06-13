//
//  TimerViewModel.swift
//  FocusToolkit
//
//  Drives the Pomodoro timer: countdown, phase (focus/break), session
//  persistence, and streak. MVVM — owns no SwiftUI, only @Published state.
//

import Foundation
import CoreData
import SwiftUI
import Combine

enum TimerPhase {
    case focus, breakTime

    var title: String {
        switch self {
        case .focus: return "Focus"
        case .breakTime: return "Break"
        }
    }
}

@MainActor
final class TimerViewModel: ObservableObject {
    // Configurable durations (seconds).
    @Published var focusDuration: Int
    @Published var breakDuration: Int

    @Published private(set) var phase: TimerPhase = .focus
    @Published private(set) var remaining: Int
    @Published private(set) var isRunning = false
    /// Total seconds for the current phase (denominator for the ring).
    @Published private(set) var total: Int

    @Published private(set) var completedToday: Int = 0
    @Published private(set) var streak: Int = 0

    private var timer: Timer?
    private var currentSession: FocusSession?
    private var context: NSManagedObjectContext?
    private var notificationsEnabled = true

    init(focusMinutes: Int = 25, breakMinutes: Int = 5) {
        self.focusDuration = focusMinutes * 60
        self.breakDuration = breakMinutes * 60
        self.remaining = focusMinutes * 60
        self.total = focusMinutes * 60
    }

    /// Inject the CoreData context once the view appears.
    func configure(context: NSManagedObjectContext, focusMinutes: Int, breakMinutes: Int, notificationsEnabled: Bool) {
        self.context = context
        self.notificationsEnabled = notificationsEnabled
        // Apply latest settings only when idle to avoid disrupting a running timer.
        if !isRunning && currentSession == nil {
            focusDuration = focusMinutes * 60
            breakDuration = breakMinutes * 60
            if phase == .focus { setRemaining(focusDuration) } else { setRemaining(breakDuration) }
        }
        refreshStats()
    }

    // MARK: Derived

    var progress: Double {
        guard total > 0 else { return 0 }
        return Double(total - remaining) / Double(total)
    }

    var timeString: String {
        let m = remaining / 60
        let s = remaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: Controls

    func startPause() {
        if isRunning { pause() } else { start() }
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        Haptics.medium()

        // Begin a focus session record when starting a fresh focus phase.
        if phase == .focus && currentSession == nil, let context {
            currentSession = FocusSession.create(in: context, duration: focusDuration)
        }

        if notificationsEnabled {
            if phase == .focus {
                NotificationService.shared.scheduleSessionEnd(after: TimeInterval(remaining))
            } else {
                NotificationService.shared.scheduleBreakEnd(after: TimeInterval(remaining))
            }
        }

        let t = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            // Timer is scheduled on the main run loop; hop to the main actor.
            Task { @MainActor [weak self] in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func pause() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        NotificationService.shared.cancelSessionNotifications()
        Haptics.tap()
    }

    /// Stop and reset current phase. If focusing, mark session incomplete & save.
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        NotificationService.shared.cancelSessionNotifications()

        if phase == .focus, let session = currentSession {
            session.endDate = Date()
            session.isCompleted = false
            save()
        }
        currentSession = nil
        setRemaining(phase == .focus ? focusDuration : breakDuration)
        Haptics.warning()
        refreshStats()
    }

    private func tick() {
        guard remaining > 0 else {
            phaseCompleted()
            return
        }
        remaining -= 1
    }

    private func phaseCompleted() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        Haptics.success()

        if phase == .focus {
            // Persist completed focus session.
            if let session = currentSession {
                session.endDate = Date()
                session.isCompleted = true
                save()
            }
            currentSession = nil
            refreshStats()
            // Transition to break.
            phase = .breakTime
            setRemaining(breakDuration)
        } else {
            // Break finished → back to focus, ready to start.
            phase = .focus
            setRemaining(focusDuration)
        }
    }

    private func setRemaining(_ seconds: Int) {
        total = seconds
        remaining = seconds
    }

    func skipPhase() {
        phaseCompleted()
    }

    private func save() {
        guard let context, context.hasChanges else { return }
        try? context.save()
    }

    // MARK: Stats

    func refreshStats() {
        guard let context else { return }
        let sessions = (try? context.fetch(FocusSession.completedRequest())) ?? []
        completedToday = sessions.filter { DateUtils.isSameDay($0.startDate, Date()) }.count
        streak = Self.computeStreak(from: sessions)
    }

    /// Consecutive days (ending today or yesterday) with ≥1 completed session.
    static func computeStreak(from sessions: [FocusSession]) -> Int {
        let days = Set(sessions.map { DateUtils.startOfDay($0.startDate) })
        guard !days.isEmpty else { return 0 }

        let cal = DateUtils.calendar
        var streak = 0
        var cursor = DateUtils.startOfDay(Date())

        // Allow streak to count if today has none but yesterday does.
        if !days.contains(cursor) {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: cursor),
                  days.contains(yesterday) else { return 0 }
            cursor = yesterday
        }

        while days.contains(cursor) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return streak
    }
}
