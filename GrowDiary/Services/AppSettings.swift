import Foundation

enum AppSettings {
    private static let iCloudKey = "growdiary.icloud.enabled"
    private static let photosMigratedKey = "growdiary.icloud.photosMigrated"
    private static let appLockKey = "growdiary.applock.enabled"
    private static let diaryReminderKey = "growdiary.notification.diary.enabled"
    private static let diaryReminderHourKey = "growdiary.notification.diary.hour"
    private static let diaryReminderMinuteKey = "growdiary.notification.diary.minute"
    private static let growthReminderKey = "growdiary.notification.growth.enabled"
    private static let growthReminderWeekdayKey = "growdiary.notification.growth.weekday"
    private static let growthReminderHourKey = "growdiary.notification.growth.hour"
    private static let growthReminderMinuteKey = "growdiary.notification.growth.minute"
    private static let spotlightKey = "growdiary.spotlight.enabled"

    static var isCloudSyncEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: iCloudKey) }
        set { UserDefaults.standard.set(newValue, forKey: iCloudKey) }
    }

    static var hasMigratedPhotosToCloud: Bool {
        get { UserDefaults.standard.bool(forKey: photosMigratedKey) }
        set { UserDefaults.standard.set(newValue, forKey: photosMigratedKey) }
    }

    static var isAppLockEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: appLockKey) }
        set { UserDefaults.standard.set(newValue, forKey: appLockKey) }
    }

    static var isDiaryReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: diaryReminderKey) }
        set { UserDefaults.standard.set(newValue, forKey: diaryReminderKey) }
    }

    static var diaryReminderHour: Int {
        get {
            let value = UserDefaults.standard.object(forKey: diaryReminderHourKey) as? Int
            return value ?? 20
        }
        set { UserDefaults.standard.set(newValue, forKey: diaryReminderHourKey) }
    }

    static var diaryReminderMinute: Int {
        get {
            let value = UserDefaults.standard.object(forKey: diaryReminderMinuteKey) as? Int
            return value ?? 0
        }
        set { UserDefaults.standard.set(newValue, forKey: diaryReminderMinuteKey) }
    }

    static var isGrowthReminderEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: growthReminderKey) }
        set { UserDefaults.standard.set(newValue, forKey: growthReminderKey) }
    }

    static var growthReminderWeekday: Int {
        get {
            let value = UserDefaults.standard.object(forKey: growthReminderWeekdayKey) as? Int
            return value ?? 1
        }
        set { UserDefaults.standard.set(newValue, forKey: growthReminderWeekdayKey) }
    }

    static var growthReminderHour: Int {
        get {
            let value = UserDefaults.standard.object(forKey: growthReminderHourKey) as? Int
            return value ?? 10
        }
        set { UserDefaults.standard.set(newValue, forKey: growthReminderHourKey) }
    }

    static var growthReminderMinute: Int {
        get {
            let value = UserDefaults.standard.object(forKey: growthReminderMinuteKey) as? Int
            return value ?? 0
        }
        set { UserDefaults.standard.set(newValue, forKey: growthReminderMinuteKey) }
    }

    static var isSpotlightEnabled: Bool {
        get {
            if UserDefaults.standard.object(forKey: spotlightKey) == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: spotlightKey)
        }
        set { UserDefaults.standard.set(newValue, forKey: spotlightKey) }
    }

    static var diaryReminderDate: Date {
        get {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            components.hour = diaryReminderHour
            components.minute = diaryReminderMinute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            diaryReminderHour = components.hour ?? 20
            diaryReminderMinute = components.minute ?? 0
        }
    }

    static var growthReminderDate: Date {
        get {
            var components = Calendar.current.dateComponents([.year, .month, .day], from: .now)
            components.hour = growthReminderHour
            components.minute = growthReminderMinute
            return Calendar.current.date(from: components) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            growthReminderHour = components.hour ?? 10
            growthReminderMinute = components.minute ?? 0
        }
    }
}
