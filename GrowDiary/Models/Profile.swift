import Foundation
import SwiftData

@Model
final class Profile {
    var id: UUID
    var name: String
    var typeRawValue: String
    var birthDate: Date
    var notes: String
    var avatarPhotoPath: String?
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \DiaryEntry.profile)
    var entries: [DiaryEntry]

    init(
        name: String,
        type: ProfileType,
        birthDate: Date,
        notes: String = "",
        avatarPhotoPath: String? = nil
    ) {
        id = UUID()
        self.name = name
        typeRawValue = type.rawValue
        self.birthDate = birthDate
        self.notes = notes
        self.avatarPhotoPath = avatarPhotoPath
        createdAt = Date()
        entries = []
    }

    var type: ProfileType {
        get { ProfileType(rawValue: typeRawValue) ?? .baby }
        set { typeRawValue = newValue.rawValue }
    }

    var sortedEntries: [DiaryEntry] {
        entries.sorted { $0.date > $1.date }
    }

    var ageDescription: String {
        AgeFormatter.description(since: birthDate)
    }
}

enum AgeFormatter {
    static func description(since birthDate: Date, reference: Date = .now) -> String {
        let components = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: birthDate,
            to: reference
        )

        let years = components.year ?? 0
        let months = components.month ?? 0
        let days = components.day ?? 0

        if years > 0 {
            if months > 0 {
                return "\(years) 歲 \(months) 個月"
            }
            return "\(years) 歲"
        }

        if months > 0 {
            if days > 0 {
                return "\(months) 個月 \(days) 天"
            }
            return "\(months) 個月"
        }

        return "\(max(days, 0)) 天"
    }
}
