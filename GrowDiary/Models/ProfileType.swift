import Foundation

enum ProfileType: String, Codable, CaseIterable, Identifiable {
    case baby
    case pet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .baby: L10n.string("profile.type.baby")
        case .pet: L10n.string("profile.type.pet")
        }
    }

    var systemImage: String {
        switch self {
        case .baby: "figure.and.child.holdinghands"
        case .pet: "pawprint.fill"
        }
    }
}
