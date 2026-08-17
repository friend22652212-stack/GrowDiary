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
    @Relationship(deleteRule: .cascade, inverse: \GrowthMetric.profile)
    var growthMetrics: [GrowthMetric]
    @Relationship(deleteRule: .cascade, inverse: \Milestone.profile)
    var milestones: [Milestone]

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
        growthMetrics = []
        milestones = []
    }

    var type: ProfileType {
        get { ProfileType(rawValue: typeRawValue) ?? .baby }
        set { typeRawValue = newValue.rawValue }
    }

    var sortedEntries: [DiaryEntry] {
        entries.sorted { $0.date > $1.date }
    }

    var sortedGrowthMetrics: [GrowthMetric] {
        growthMetrics.sorted { $0.date > $1.date }
    }

    var sortedMilestones: [Milestone] {
        milestones.sorted { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return !lhs.isCompleted
            }
            return lhs.sortOrder < rhs.sortOrder
        }
    }

    var completedMilestoneCount: Int {
        milestones.filter(\.isCompleted).count
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
                return L10n.format("age.format.yearsAndMonths", years, months)
            }
            return L10n.format("age.format.years", years)
        }

        if months > 0 {
            if days > 0 {
                return L10n.format("age.format.monthsAndDays", months, days)
            }
            return L10n.format("age.format.months", months)
        }

        return L10n.format("age.format.days", max(days, 0))
    }
}
