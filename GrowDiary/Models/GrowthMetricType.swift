import Foundation

enum GrowthMetricType: String, Codable, CaseIterable, Identifiable {
    case height
    case weight
    case headCircumference

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .height: L10n.string("growth.type.height")
        case .weight: L10n.string("growth.type.weight")
        case .headCircumference: L10n.string("growth.type.headCircumference")
        }
    }

    var unit: String {
        switch self {
        case .height, .headCircumference: L10n.string("unit.cm")
        case .weight: L10n.string("unit.kg")
        }
    }

    var systemImage: String {
        switch self {
        case .height: "ruler"
        case .weight: "scalemass"
        case .headCircumference: "circle.dashed"
        }
    }

    static func available(for profileType: ProfileType) -> [GrowthMetricType] {
        switch profileType {
        case .baby: GrowthMetricType.allCases
        case .pet: [.weight]
        }
    }
}
