import Foundation
import UserNotifications

struct DailyReminder {
    let trackerId: UUID
    let trackerName: String
    let hour: Int
    let minute: Int
}

struct ReminderScheduler {
    static let shared = ReminderScheduler()

    private let center = UNUserNotificationCenter.current()

    func requestAuthorizationIfNeeded() async -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    func schedule(_ reminder: DailyReminder) async {
        let content = UNMutableNotificationContent()
        content.title = "BodyLog"
        content.body = "记录你的 \(reminder.trackerName) 今天的变化"
        content.sound = .default

        var date = DateComponents()
        date.hour = reminder.hour
        date.minute = reminder.minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let request = UNNotificationRequest(
            identifier: identifier(for: reminder.trackerId),
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancel(trackerId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier(for: trackerId)])
    }

    private func identifier(for trackerId: UUID) -> String {
        "tracker.reminder.\(trackerId.uuidString)"
    }
}
