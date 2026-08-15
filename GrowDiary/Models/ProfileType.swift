import Foundation

enum ProfileType: String, Codable, CaseIterable, Identifiable {
    case baby
    case pet

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .baby: "寶寶"
        case .pet: "寵物"
        }
    }

    var systemImage: String {
        switch self {
        case .baby: "figure.and.child.holdinghands"
        case .pet: "pawprint.fill"
        }
    }
}
