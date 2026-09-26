//
//  NotificationManager.swift
//  PPMonsterTracker
//
//  Created by Mark Mavromatis on 8/12/26.
//

import UserNotifications

enum NotificationManager {
    private static let walkReminderID = "com.ppmonstertracker.walk-reminder"

    static func requestAuthorization() async {
        _ = try? await UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge])
    }

    /// Cancels any pending walk reminder and schedules a fresh one 3 hours from now.
    /// Calling this on every save ensures multiple events on the same walk don't
    /// produce multiple notifications — only the last event's timer fires.
    static func scheduleWalkReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [walkReminderID])

        let content = UNMutableNotificationContent()
        content.title = "Time to walk PP Monster! 🐾"
        content.body = "It's been 3 hours since the last bathroom break."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 3 * 60 * 60,
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: walkReminderID,
            content: content,
            trigger: trigger
        )
        center.add(request)
    }
}
