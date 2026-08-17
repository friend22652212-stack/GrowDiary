import Foundation
import UserNotifications

enum NotificationService {
    static let diaryReminderID = "growdiary.reminder.diary"
    static let growthReminderID = "growdiary.reminder.growth"

    static func requestAuthorizationIfNeeded() async -> Bool {
        let center = UNUserNotificationCenter.current()
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

    static func rescheduleAll() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [diaryReminderID, growthReminderID])

        guard await requestAuthorizationIfNeeded() else { return }

        if AppSettings.isDiaryReminderEnabled {
            await scheduleDiaryReminder()
        }

        if AppSettings.isGrowthReminderEnabled {
            await scheduleGrowthReminder()
        }
    }

    private static func scheduleDiaryReminder() async {
        var components = DateComponents()
        components.hour = AppSettings.diaryReminderHour
        components.minute = AppSettings.diaryReminderMinute

        let content = UNMutableNotificationContent()
        content.title = L10n.string("notification.diary.title")
        content.body = L10n.string("notification.diary.body")
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: diaryReminderID, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    private static func scheduleGrowthReminder() async {
        var components = DateComponents()
        components.weekday = AppSettings.growthReminderWeekday
        components.hour = AppSettings.growthReminderHour
        components.minute = AppSettings.growthReminderMinute

        let content = UNMutableNotificationContent()
        content.title = L10n.string("notification.growth.title")
        content.body = L10n.string("notification.growth.body")
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: growthReminderID, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
