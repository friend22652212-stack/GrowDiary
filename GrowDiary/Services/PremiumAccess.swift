import Foundation

enum PremiumAccess {
    static var freeDiaryHistoryDays: Int { SubscriptionConstants.freeDiaryHistoryDays }

    static func diaryHistoryCutoffDate(reference: Date = .now) -> Date {
        Calendar.current.date(byAdding: .day, value: -freeDiaryHistoryDays, to: reference) ?? reference
    }

    static func isDiaryEntryAccessible(_ entry: DiaryEntry, isPremium: Bool) -> Bool {
        isDiaryDateAccessible(entry.date, isPremium: isPremium)
    }

    static func isDiaryDateAccessible(_ date: Date, isPremium: Bool) -> Bool {
        guard !isPremium else { return true }
        return date >= diaryHistoryCutoffDate()
    }

    static func accessibleEntries(from entries: [DiaryEntry], isPremium: Bool) -> [DiaryEntry] {
        entries.filter { isDiaryEntryAccessible($0, isPremium: isPremium) }
    }

    static func lockedEntryCount(in entries: [DiaryEntry], isPremium: Bool) -> Int {
        guard !isPremium else { return 0 }
        return entries.count - accessibleEntries(from: entries, isPremium: isPremium).count
    }
}
