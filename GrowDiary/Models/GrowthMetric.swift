import Foundation
import SwiftData

@Model
final class GrowthMetric {
    var id: UUID
    var typeRawValue: String
    var value: Double
    var date: Date
    var notes: String
    var createdAt: Date
    var profile: Profile?

    init(
        type: GrowthMetricType,
        value: Double,
        date: Date = .now,
        notes: String = "",
        profile: Profile? = nil
    ) {
        id = UUID()
        typeRawValue = type.rawValue
        self.value = value
        self.date = date
        self.notes = notes
        createdAt = Date()
        self.profile = profile
    }

    var type: GrowthMetricType {
        get { GrowthMetricType(rawValue: typeRawValue) ?? .weight }
        set { typeRawValue = newValue.rawValue }
    }

    var formattedValue: String {
        String(format: "%.1f %@", value, type.unit)
    }
}
